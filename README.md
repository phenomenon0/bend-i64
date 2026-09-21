# bend-i64

**Signed 64-bit integers in pure Bend** — two's complement over one `Word(64n)`,
with a machine-checked commutation law and the signed layer made explicit:
negation, sign-aware comparison, arithmetic shift. No FFI, no intrinsics, no
`unsafe`, no compiler change.

**Published on BendHub: [`0x9f15483a7cabc6e91e5092cc41829c43`](https://hub.bend-lang.com/0x9f15483a7cabc6e91e5092cc41829c43)** (2 files, 7,419 bytes).

```bend
import Base
import ./i64.bend as I64

def main() -> IO(Unit):
  do IO<Unit>:
    m : I64.I64 = I64.min()
    n : I64.I64 = I64.max()
    u : Unit <- IO.print("signed: min < max is True, though min's bits say otherwise\n")
    IO.print("done\n")
```

## The signed layer, exactly

- **Arithmetic is bit-identical to unsigned two's complement** — `add`, `sub`,
  `mul`, bitwise ops all ride the same width-64 `Word.*` instantiations, and
  `add_comm` transfers to the signed reading *because addition ignores the
  sign*. The law is proved by instantiating Base's own generic inductive lemma
  `Word.add_comm(64n, …)` — no new induction.
- **`neg(x)` = `0 − x`** (two's complement): `neg(1) == -1`, `-1 + 1 == 0`,
  and the overflow classic `neg(min) == min`.
- **Comparison is sign-aware by biasing**: `cmp` XORs both operands with
  2⁶³ before the unsigned compare — so `min < max` is `True` while the raw
  bits say the opposite. That is the trick, and the demo pins it.
- **`shr.s` replicates the sign**: arithmetic right shift fills with the sign
  bit (`min >>s 1 == -2⁶²`), where `shr` is the logical shift.

## Honest boundaries

- `to_nat` is valid for `0 ≤ v ≤ 2⁴⁸−1`; negative values read as their bit
  pattern (documented, not converted).
- `shl.n` / `shr.s.n` are bit-at-a-time folds — O(n).
- Division is not implemented yet.
- Checked with Bend 2.0.17. The Bend kernel, Base, compiler, C toolchain and
  CPU are trusted.

## API

`zero one minus_one min max add sub mul inc neg and or xor not shl shl_n shr
shr_s shr_s_n cmp is_eq is_lt is_gt is_neg to_nat`

## Performance (measured — the honest number)

10,000,000 incrementing adds, same program, Ryzen 7 7700X, Bend 2.0.17
(the i64 lane; the u64 twin measures identically — same `Word(64n)` path):

| lane | time | per op |
|---|---:|---:|
| native C control (`long long`) | ~2 ms | sub-nanosecond (loop collapses under -O2) |
| Bend interpreter | 1.47 s | ~147 ns |
| Bend → C, `-O2` | 2.2 s | ~220 ns |

**Slow, and worth saying plainly:** width-64 generic `Word.*` compiles to the
structural bit-at-a-time walk (only width-32 and `F64` have native op tables),
so a compiled `I64` op costs about what an interpreted one costs,
~10²–10³× the native control. Use it for cold paths (IDs, occasional
arithmetic, the proof story) today; for hot loops use pairs of `U32` with
manual carry — or wait for a native `Word(64n)` lowering (mechanical: mirror
the `F64` op tables). This package is the working spec — and the benchmark —
for that change.

## Verify

```sh
./verify.sh
```

Seven steps: strict check (laws, no holes); interpret / JS / C agree byte for
byte; **a mutation of `add` is refused by the checker** (the witness is
load-bearing); and **a mutation that drops the sign bias from the comparison is
caught by the demo** — laws where a law is provable, pins where behavior is
the statement.

## BendHub

```sh
bend package.bend --publish
```

Sibling package: [`bend-u64`](https://github.com/phenomenon0/bend-u64) — the
unsigned twin. Same shape, same law, same honesty.
