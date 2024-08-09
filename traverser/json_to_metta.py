from json import loads

untyped = True


with open("tinkerpop-modern.json") as f:
    ds = [loads(line) for line in f.readlines()]


def dict_generator(indict, pre=None):
    pre = pre[:] if pre else []
    if isinstance(indict, dict):
        if untyped and "@value" in indict and "@type" in indict:
            yield pre + [indict["@value"]]
            return
        for key, value in indict.items():
            if isinstance(value, dict):
                yield from dict_generator(value, pre + [key])
            elif isinstance(value, list) or isinstance(value, tuple):
                for i, v in enumerate(value):
                    yield from dict_generator(v, pre + [(key, i)])
            else:
                yield pre + [key, value]
    else:
        yield pre + [indict]


with open("tinkerpop-modern.metta", "w") as f:
    for i, d in enumerate(ds):
        for path in dict_generator(d):
            s = path[-1]
            for item in reversed(path[:-1]):
                if isinstance(item, tuple):
                    s = f"({' '.join(map(str, item))} {s})"
                else:
                    s = f"({item} {s})"
            f.write(f"(json {i} {s})\n")
