"""Backend for the dynamic espanso matches in match/base.yml.

Usage: helper.py <command> <args...>
  offset <sign> <n> <unit>    relative ISO 8601 date (unit: d/w/m/y)
  calc <expr>                 evaluate a Python math expression
  convert <value> <src> <dst> unit conversion
  random [args]               "", "n" or "a,b" -> random.randint semantics
"""

import calendar
import datetime
import math
import random
import sys


def offset(sign, n, unit):
    n = int(n) * (-1 if sign == "-" else 1)
    today = datetime.date.today()
    if unit == "d":
        return (today + datetime.timedelta(days=n)).isoformat()
    if unit == "w":
        return (today + datetime.timedelta(weeks=n)).isoformat()
    # Months/years clamp to the last day, so Jan 31 +1m is Feb 28/29.
    months = n * 12 if unit == "y" else n
    y, m = divmod(today.year * 12 + today.month - 1 + months, 12)
    day = min(today.day, calendar.monthrange(y, m + 1)[1])
    return datetime.date(y, m + 1, day).isoformat()


CALC_NAMES = {k: v for k, v in vars(math).items() if not k.startswith("_")}
CALC_NAMES.update(
    abs=abs, round=round, min=min, max=max, sum=sum, pow=pow, divmod=divmod,
    int=int, float=float, hex=hex, bin=bin, oct=oct,
)


def fmt(x):
    if isinstance(x, float):
        if x.is_integer() and abs(x) < 1e15:
            return str(int(x))
        return f"{x:.10g}"
    return str(x)


def calc(expr):
    try:
        result = eval(expr, {"__builtins__": {}}, CALC_NAMES)
    except Exception as e:
        # Keep what was typed so a typo doesn't eat the expression.
        return f"{expr} [{type(e).__name__}: {e}]"
    return fmt(result)


# Factor to the base unit of each dimension (m, kg, l, m/s, B, s).
UNITS = {
    "length": {"mm": 1e-3, "cm": 1e-2, "m": 1, "km": 1e3, "in": 0.0254,
               "ft": 0.3048, "yd": 0.9144, "mi": 1609.344, "nmi": 1852},
    "mass": {"mg": 1e-6, "g": 1e-3, "kg": 1, "t": 1e3, "oz": 0.028349523125,
             "lb": 0.45359237, "st": 6.35029318},
    "volume": {"ml": 1e-3, "l": 1, "tsp": 0.00492892159375,
               "tbsp": 0.01478676478125, "floz": 0.0295735295625,
               "cup": 0.2365882365, "pt": 0.473176473, "qt": 0.946352946,
               "gal": 3.785411784},
    "speed": {"mps": 1, "kph": 1 / 3.6, "kmh": 1 / 3.6, "mph": 0.44704,
              "kn": 0.514444},
    "data": {"b": 1, "kb": 1e3, "mb": 1e6, "gb": 1e9, "tb": 1e12,
             "kib": 2**10, "mib": 2**20, "gib": 2**30, "tib": 2**40},
    "time": {"ms": 1e-3, "s": 1, "min": 60, "h": 3600, "day": 86400,
             "wk": 604800, "yr": 31557600},
}
TEMPS = {
    "c": (lambda c: c, lambda c: c),
    "f": (lambda f: (f - 32) * 5 / 9, lambda c: c * 9 / 5 + 32),
    "k": (lambda k: k - 273.15, lambda c: c + 273.15),
}


def convert(value, src, dst):
    v, s, d = float(value), src.lower(), dst.lower()
    if s in TEMPS and d in TEMPS:
        return f"{fmt(round(TEMPS[d][1](TEMPS[s][0](v)), 6))} {dst}"
    for table in UNITS.values():
        if s in table and d in table:
            return f"{fmt(round(v * table[s] / table[d], 6))} {dst}"
    return f"{value}{src}>{dst} [unknown conversion]"


def rand(args=""):
    nums = [int(a) for a in args.split(",") if a.strip()]
    if not nums:
        nums = [100]
    lo, hi = (1, nums[0]) if len(nums) == 1 else nums[:2]
    return str(random.randint(min(lo, hi), max(lo, hi)))


if __name__ == "__main__":
    cmd, *args = sys.argv[1:]
    commands = {"offset": offset, "calc": calc, "convert": convert, "random": rand}
    print(commands[cmd](*args), end="")
