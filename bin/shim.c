#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <ctype.h>

typedef struct {
    char **v;
    int n;
    int cap;
} StrVec;

static void sv_init(StrVec *sv) {
    sv->v = NULL; sv->n = 0; sv->cap = 0;
}
static void sv_push(StrVec *sv, const char *s) {
    if (sv->n + 1 >= sv->cap) {
        sv->cap = sv->cap ? sv->cap * 2 : 32;
        sv->v = (char**)realloc(sv->v, (size_t)sv->cap * sizeof(char*));
        if (!sv->v) { fprintf(stderr, "oom\n"); exit(2); }
    }
    sv->v[sv->n++] = _strdup(s ? s : "");
    sv->v[sv->n] = NULL;
}
static void sv_free(StrVec *sv) {
    for (int i = 0; i < sv->n; i++) free(sv->v[i]);
    free(sv->v);
}

static int ieq_prefix(const char *s, const char *pfx) {
    while (*pfx && *s) {
        if (tolower((unsigned char)*s) != tolower((unsigned char)*pfx)) return 0;
        s++; pfx++;
    }
    return *pfx == 0;
}

static int is_switch(const char *a) {
    return a && (a[0] == '/' || a[0] == '-');
}

// Returns pointer to value part if switch like "/Ifoo" or "/Foout.obj", else NULL.
static const char* switch_value_inline(const char *a) {
    if (!is_switch(a)) return NULL;
    // "/Ifoo" => "foo"
    if ((tolower((unsigned char)a[1])=='i' || tolower((unsigned char)a[1])=='d') && a[2]) return a + 2;
    // "/Fo..." "/Fe..."
    if (tolower((unsigned char)a[1])=='f' && (tolower((unsigned char)a[2])=='o' || tolower((unsigned char)a[2])=='e') && a[3]) return a + 3;
    // "/std:..." "/O2" etc are handled separately
    return NULL;
}

static void push_with_prefix(StrVec *out, const char *pfx, const char *val) {
    size_t lp = strlen(pfx), lv = strlen(val);
    char *buf = (char*)malloc(lp + lv + 1);
    if (!buf) { fprintf(stderr, "oom\n"); exit(2); }
    memcpy(buf, pfx, lp);
    memcpy(buf + lp, val, lv);
    buf[lp + lv] = 0;
    sv_push(out, buf);
    free(buf);
}

static int has_ext_ci(const char *path, const char *ext) {
    size_t lp = strlen(path), le = strlen(ext);
    if (lp < le) return 0;
    const char *tail = path + (lp - le);
    for (size_t i = 0; i < le; i++) {
        if (tolower((unsigned char)tail[i]) != tolower((unsigned char)ext[i])) return 0;
    }
    return 1;
}

int main(int argc, char **argv) {
    const char *zig = getenv("ZIG");
    if (!zig || !*zig) zig = "zig";

    int debug = 0;
    const char *dbg = getenv("CL_SHIM_DEBUG");
    if (dbg && *dbg && strcmp(dbg, "0") != 0) debug = 1;

    // Heuristics: use zig c++ if /TP or any .cpp/.cxx/.cc present
    int use_cpp = 0;

    // Parse and map
    StrVec out;
    sv_init(&out);

    sv_push(&out, zig);
    // we will insert "cc"/"c++" after we decide
    int subcmd_index = out.n;
    sv_push(&out, "cc"); // placeholder

    // Prefer MSVC target to match treesitter expectations on Windows
    // (safe even if you later pass -target yourself)
    sv_push(&out, "-target");
    sv_push(&out, "x86_64-windows-msvc");

    // Many MSVC-isms are accepted by clang; zig cc is clang-based.
    // Keep this modest to reduce surprises:
    // sv_push(&out, "-fms-compatibility"); // optional; can help in some cases

    int compile_only = 0;
    int saw_link = 0;

    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        if (!a) continue;

        if (!saw_link && is_switch(a) && (ieq_prefix(a, "/link") || ieq_prefix(a, "-link"))) {
            // For nvim-treesitter обычно не нужно. Всё, что после /link — linker args.
            // Можно расширять по мере надобности.
            saw_link = 1;
            continue;
        }
        if (saw_link) {
            // Ignore linker args by default (tree-sitter обычно собирается /c)
            continue;
        }

        // Language mode
        if (is_switch(a) && (ieq_prefix(a, "/TP") || ieq_prefix(a, "-TP"))) { use_cpp = 1; continue; }
        if (is_switch(a) && (ieq_prefix(a, "/TC") || ieq_prefix(a, "-TC"))) { use_cpp = 0; continue; }

        // Quiet/noise flags
        if (is_switch(a) && (ieq_prefix(a, "/nologo") || ieq_prefix(a, "-nologo"))) continue;
        if (is_switch(a) && (ieq_prefix(a, "/diagnostics:") || ieq_prefix(a, "-diagnostics:"))) continue;

        // Compile only
        if (is_switch(a) && (ieq_prefix(a, "/c") || ieq_prefix(a, "-c"))) { compile_only = 1; sv_push(&out, "-c"); continue; }

        // Output file: /Fo(out.obj) or /Fo out.obj
        if (is_switch(a) && (ieq_prefix(a, "/Fo") || ieq_prefix(a, "-Fo"))) {
            const char *val = switch_value_inline(a);
            if (!val) {
                if (i + 1 < argc) val = argv[++i];
            }
            if (val && *val) {
                sv_push(&out, "-o");
                sv_push(&out, val);
            }
            continue;
        }
        // Output exe: /Fe(out.exe) or /Fe out.exe  (на случай если вдруг)
        if (is_switch(a) && (ieq_prefix(a, "/Fe") || ieq_prefix(a, "-Fe"))) {
            const char *val = switch_value_inline(a);
            if (!val) {
                if (i + 1 < argc) val = argv[++i];
            }
            if (val && *val) {
                sv_push(&out, "-o");
                sv_push(&out, val);
            }
            continue;
        }

        // Include dirs: /Ipath or /I path
        if (is_switch(a) && (ieq_prefix(a, "/I") || ieq_prefix(a, "-I"))) {
            const char *val = switch_value_inline(a);
            if (!val) {
                if (i + 1 < argc) val = argv[++i];
            }
            if (val && *val) push_with_prefix(&out, "-I", val);
            continue;
        }

        // Defines: /DNAME or /D NAME=VAL
        if (is_switch(a) && (ieq_prefix(a, "/D") || ieq_prefix(a, "-D"))) {
            const char *val = switch_value_inline(a);
            if (!val) {
                if (i + 1 < argc) val = argv[++i];
            }
            if (val && *val) push_with_prefix(&out, "-D", val);
            continue;
        }

        // Optimization: /O2 /Od
        if (is_switch(a) && (ieq_prefix(a, "/O2") || ieq_prefix(a, "-O2"))) { sv_push(&out, "-O2"); continue; }
        if (is_switch(a) && (ieq_prefix(a, "/O1") || ieq_prefix(a, "-O1"))) { sv_push(&out, "-O1"); continue; }
        if (is_switch(a) && (ieq_prefix(a, "/Od") || ieq_prefix(a, "-Od"))) { sv_push(&out, "-O0"); continue; }

        // Debug info: /Zi /Z7 (ignore or map)
        if (is_switch(a) && (ieq_prefix(a, "/Zi") || ieq_prefix(a, "-Zi"))) { sv_push(&out, "-g"); continue; }
        if (is_switch(a) && (ieq_prefix(a, "/Z7") || ieq_prefix(a, "-Z7"))) { sv_push(&out, "-g"); continue; }

        // Warnings: /W0..4 (rough mapping)
        if (is_switch(a) && (strlen(a) == 3) && (tolower((unsigned char)a[1])=='w') && isdigit((unsigned char)a[2])) {
            switch (a[2]) {
                case '0': sv_push(&out, "-w"); break;
                default: sv_push(&out, "-Wall"); break;
            }
            continue;
        }

        // C standard: /std:c11, /std:c17, /std:c++17, etc.
        if (is_switch(a) && (ieq_prefix(a, "/std:") || ieq_prefix(a, "-std:"))) {
            const char *val = a + 5; // after "/std:"
            if (*val) {
                // MSVC spells: c11,c17,c++14,c++17,c++20,c++latest
                if (ieq_prefix(val, "c++")) use_cpp = 1;
                // Convert "c++17" -> "c++17" (clang accepts), "c17" -> "c17"
                push_with_prefix(&out, "-std=", val);
            }
            continue;
        }

        // Exception model /EHsc etc — ignore (clang default is fine for parsing/building tree-sitter)
        if (is_switch(a) && (ieq_prefix(a, "/EH") || ieq_prefix(a, "-EH"))) continue;

        // Runtime library flags /MD /MT etc — ignore for our use-case
        if (is_switch(a) && (ieq_prefix(a, "/MD") || ieq_prefix(a, "/MT") || ieq_prefix(a, "-MD") || ieq_prefix(a, "-MT"))) continue;

        // Anything else:
        // - If it's a source file and looks like C++ -> use_cpp
        if (!is_switch(a)) {
            if (has_ext_ci(a, ".cpp") || has_ext_ci(a, ".cxx") || has_ext_ci(a, ".cc")) use_cpp = 1;
            sv_push(&out, a);
            continue;
        }

        // Unknown switch: try passing through in a clang-ish way.
        // Many /something MSVC flags won't work; but for treesitter обычно не критично.
        // We’ll drop the leading '/' and prefix '-' for some common patterns is risky,
        // so better: ignore unknown MSVC switches silently.
        // If you want to be strict, print in debug.
        if (debug) fprintf(stderr, "[cl_shim] ignoring unknown arg: %s\n", a);
    }

    // Force compile-only if no /c but treesitter expects objs? (leave as user said)
    (void)compile_only;

    // Set correct subcommand (cc vs c++)
    free(out.v[subcmd_index]);
    out.v[subcmd_index] = _strdup(use_cpp ? "c++" : "cc");

    if (debug) {
        fprintf(stderr, "[cl_shim] exec:");
        for (int i = 0; i < out.n; i++) fprintf(stderr, " %s", out.v[i]);
        fprintf(stderr, "\n");
    }

    // Run zig
    int rc = _spawnvp(_P_WAIT, out.v[0], (const char* const*)out.v);
    if (rc == -1) {
        perror("[cl_shim] _spawnvp failed");
        sv_free(&out);
        return 1;
    }

    sv_free(&out);
    return rc;
}
