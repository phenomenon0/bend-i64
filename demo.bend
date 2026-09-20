import Base
import ./i64.bend as I64

# The demo: seven signed checks, identical output on every lane.

def t1() -> Bool:
  I64.is_eq(I64.neg(I64.one()), I64.minus_one())       # 0 - 1 == -1

def t2() -> Bool:
  I64.is_eq(I64.add(I64.minus_one(), I64.one()), I64.zero())   # -1 + 1 == 0

def t3() -> Bool:
  I64.is_eq(I64.neg(I64.min()), I64.min())             # -min overflows to min

def t4() -> Bool:
  I64.is_lt(I64.min(), I64.max())                      # SIGNED: unsigned would say False

def t5() -> Bool:
  I64.is_eq(I64.shr.s(I64.min()), I64.neg(I64.shl.n(62n, I64.one())))  # -2^63 >>s 1 == -2^62

def t6() -> Bool:
  I64.is_neg(I64.min())

def t7() -> Bool:
  I64.not.b(I64.is_neg(I64.max()))

def pass(b: Bool, msg: String) -> String:
  match b:
    case True{}: String.append("ok   ", msg)
    case False{}: String.append("FAIL ", msg)

def line(b: Bool, msg: String) -> IO(Unit):
  IO.print(String.append(pass(b, msg), "\n"))

def main() -> IO(Unit):
  do IO<Unit>:
    a : Unit <- line(t1(), "neg(1) == -1")
    b : Unit <- line(t2(), "-1 + 1 == 0")
    c : Unit <- line(t3(), "neg(min) == min (overflow)")
    d : Unit <- line(t4(), "signed compare: min < max (unsigned says False)")
    e : Unit <- line(t5(), "arithmetic shift: min >>s 1 == -2^62")
    f : Unit <- line(t6(), "is_neg(min)")
    g : Unit <- line(t7(), "not is_neg(max)")
    IO.print("DEMO-END\n")
