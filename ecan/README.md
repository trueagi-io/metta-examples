# ECAN + neural spreading

Example of [hyperon-ecan](https://github.com/aljojoby9/hyperon-ecan)
from MeTTa. The library is in that repo. This folder is just the sketch.

## Run

```bash
pip install "hyperon-ecan[hyperon] @ git+https://github.com/aljojoby9/hyperon-ecan.git"
metta ecan/concept_attention.metta
```

Use a current checkout. Older versions don't have `ecan-cluster` / `ecan-report`.

## What you should see

`ecan-report` prints one line of `name: sti=… focus|idle`.

1. After setup, everything is `sti=0.00 idle`.
2. After `!(ecan-stimulate dog 20)` and `!(ecan-cycle)`:
   - `dog` is in focus (STI stays above 8)
   - `wolf` has some STI, `oak` stays `0.00 idle`
3. `!(neural-similar dog)` lists mammal/wolf first
4. `!(ecan-infer)` returns `(Inheritance dog animal)`

12 is not enough. After rent, dog drops below the focus cutoff and
`ecan-infer` returns `none`. The script uses 20 on purpose.
