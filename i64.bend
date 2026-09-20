# bend-i64: a SIGNED 64-bit integer in pure Bend, two's complement over Word(64n).
# Source: https://github.com/phenomenon0/bend-i64
#
# The arithmetic is bit-identical to unsigned two's complement — add, sub, mul
# and the bitwise ops ride the same width-64 Word.* instantiations. The signed
# layer is interpretation: negation as 0 - x, SIGNED comparison by biasing both
# operands with the sign bit (x XOR 2^63) before the unsigned compare, and
# arithmetic right shift that replicates the sign.
#
# The law is machine-checked: add_comm is proved by instantiating Base's own
# generic inductive lemma Word.add_comm(64n, ...) — and it transfers to the
# signed reading exactly because addition ignores the sign.
#
# Boundaries, stated honestly:
#   - to_nat is valid for 0 <= v <= 2^48-1 (Nat immediate limit); negative
#     values read as their bit pattern and are documented, not converted.
#   - shl.n / shr.s.n are bit-at-a-time folds (n small); O(n).
#   - Division is not implemented yet.
#   - No FFI, no intrinsics, no unsafe; checked on stock Bend 2.0.17.
#
# Note on order: dotted defs (x.y) are defined before their first call — this
# file keeps that discipline throughout (see tests note in the README).
import Base

type I64 is Data:
  I64{data: Word(64n)}

# -- the signed reading, helpers first ---------------------------------------

def shl.n.w(n: Nat, w: Word(64n)) -> Word(64n):
  match n:
    case 0n: w
    case 1n+p: shl.n.w(p, Word.shl(64n, w))

def sign_mask.w() -> Word(64n):
  shl.n.w(63n, Word.inc(64n, Word.zero(64n)))

def bias.w(x: Word(64n)) -> Word(64n):
  Word.xor(64n, x, sign_mask.w())

def cmp.eq(c: Cmp) -> Bool:
  match c:
    case EQ{}: True{}
    case LT{}: False{}
    case GT{}: False{}

def cmp.lt(c: Cmp) -> Bool:
  match c:
    case LT{}: True{}
    case EQ{}: False{}
    case GT{}: False{}

def cmp.gt(c: Cmp) -> Bool:
  match c:
    case GT{}: True{}
    case EQ{}: False{}
    case LT{}: False{}

def ge.cmp(c: Cmp) -> Bool:
  match c:
    case GT{}: True{}
    case EQ{}: True{}
    case LT{}: False{}

def ge.w(x: Word(64n)) -> Bool:
  ge.cmp(Word.cmp(64n, x, sign_mask.w()))

def scmp.w(a: Word(64n), b: Word(64n)) -> Cmp:
  Word.cmp(64n, bias.w(a), bias.w(b))

def shrs.pick(sgn: Bool, y: Word(64n)) -> Word(64n):
  match sgn:
    case True{}: Word.or(64n, y, sign_mask.w())
    case False{}: y

def shrs.w(+x: Word(64n)) -> Word(64n):
  shrs.pick(ge.w(x), Word.shr(64n, x))

# -- constructors ------------------------------------------------------------

def zero() -> I64:
  I64{Word.zero(64n)}

def one() -> I64:
  I64{Word.inc(64n, Word.zero(64n))}

def minus_one() -> I64:
  I64{Word.not(64n, Word.zero(64n))}

def min() -> I64:
  I64{sign_mask.w()}

def max() -> I64:
  I64{Word.not(64n, sign_mask.w())}

# -- arithmetic (bit-identical to unsigned two's complement) -----------------

def add(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.add(64n, x, y)}

def sub(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.sub(64n, x, y)}

def mul(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.mul(64n, x, y)}

def inc(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{Word.inc(64n, x)}

def neg(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{Word.sub(64n, Word.zero(64n), x)}

# -- bitwise -----------------------------------------------------------------

def and(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.and(64n, x, y)}

def or(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.or(64n, x, y)}

def xor(a: I64, b: I64) -> I64:
  match a b:
    case I64{x} I64{y}:
      I64{Word.xor(64n, x, y)}

def not(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{Word.not(64n, x)}

# -- shifts: shl/shl.n logical; shr logical; shr.s / shr.s.n arithmetic -------

def shl(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{Word.shl(64n, x)}

def shl.n(n: Nat, a: I64) -> I64:
  match a:
    case I64{x}:
      I64{shl.n.w(n, x)}

def shr(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{Word.shr(64n, x)}

def shr.s(a: I64) -> I64:
  match a:
    case I64{x}:
      I64{shrs.w(x)}

def shr.s.n(n: Nat, a: I64) -> I64:
  match n:
    case 0n: a
    case 1n+p: shr.s.n(p, shr.s(a))

# -- comparison: SIGNED, by biasing both operands with the sign bit ----------

def cmp(a: I64, b: I64) -> Cmp:
  match a b:
    case I64{x} I64{y}:
      scmp.w(x, y)

def is_eq(a: I64, b: I64) -> Bool:
  cmp.eq(cmp(a, b))

def is_lt(a: I64, b: I64) -> Bool:
  cmp.lt(cmp(a, b))

def is_gt(a: I64, b: I64) -> Bool:
  cmp.gt(cmp(a, b))

def is_neg(a: I64) -> Bool:
  match a:
    case I64{x}:
      ge.w(x)

def not.b(b: Bool) -> Bool:
  match b:
    case True{}: False{}
    case False{}: True{}

# -- Nat interop (valid for 0 <= v <= 2^48-1; negative reads its bit pattern) -

def to_nat(a: I64) -> Nat:
  match a:
    case I64{x}:
      Word.to_nat(64n, x)

# -- the law: width-64 instantiation of Base's generic lemma -----------------

law add_comm:
  for a: I64
  for b: I64
  {add(a, b) == add(b, a) : I64}

def add_comm(a, b):
  match a b:
    case I64{x} I64{y}:
      Equal.cong(Word(64n), I64, w => I64{w}, Word.add(64n, x, y),
        Word.add(64n, y, x), Word.add_comm(64n, x, y))
