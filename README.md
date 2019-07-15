# csv-to-yaml

Converting a transposed CSV to YAML

## About

This is very basic Shell Script that converts a transposed CSV file to a beautiful YAML ;)

## Dependencies

- `bash`
- `csvtool` (*Package Manager*)
- `yamllint` (*Package Manager* or `pip`)

## Example

The `csv-to-yaml.sh` script works in a very simple way. You just need to pass the path of a CSV file as the first argument of the script, and the output will be a YAML file with the same name of the CSV, but with the `.yml` extention instead of `.csv`.

### Input

The input file is a **transposed CSV**. This repository includes a sample CSV file named `sample.csv`, which looks like this:

```csv
computer.specs.cpu.cores,4
computer.specs.cpu.clock,1000GHz
computer.specs.memory.slots,4
computer.specs.memory.max,32Gb
computer.price,US$499
computer.brand,Generic Brand
```

### Execution

The script is executed like this:

```bash
./csv-to-yaml.sh sample.csv
```

### Output

The output will be a file named `sample.yml` in the same directory. The file will look like this:

```yaml
---
computer:
  brand: Generic Brand
  price: US$499
  specs:
    cpu:
      clock: 1000GHz
      cores: 4
    memory:
      max: 32Gb
      slots: 4
```

___

Enjoy!
