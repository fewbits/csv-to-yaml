# CSV to YAML

A *Shell Script* tool that converts a **CSV** to **YAML**.

## About

This is a basic *Shell Script* that converts a **transposed CSV file** to a **pretty nice YAML**. :grin:

## Dependencies

- `bash`
- `csvtool` (via *Package Manager* - Used with `--transpose` option)
- `yamllint` (via *Package Manager* or `pip` - Used for validating the generated *YAML* file.)

## CSV File

The input file must be a **transposed CSV** with the format `hierarchical.key.separated.by.dots,value` per line. This repository includes a sample *CSV* file named `sample.csv`, which looks like this:

```csv
computer.brand,HellLet PackYard
computer.price,US$499.99
computer.motherboard.cpu.sockets,1
computer.motherboard.cpu.type,LGA 1151
computer.motherboard.memory.banks,4
computer.motherboard.memory.type,DDR4
computer.motherboard.memory.max,32Gb
```

If your input *CSV* file is not transposed, don't worry. You can use the option `--transpose` to transpose the *CSV* file on-the-fly.

## Example of Execution

The script is executed like this:

```bash
./csv-to-yaml.sh --file my_file.csv
```

## Script Options

The following table describes all of the current available command-line options for the script:

| **Long form** | **Short form**  | **Extra value**  | **Type**  | **Description**                                                                   |
| ------------- | --------------- | ---------------- | --------- | --------------------------------------------------------------------------------- |
| `--debug`     | `-D`            | None             | Optional  | Display debug messages in the log (used for *Debugging*)                          |
| `--delimiter` | `-d`            | `CHARACTER`      | Optional  | Alternative delimiter character to use instead of comma (,)                       |
| `--file`      | `-f`            | `FILE_PATH.csv`  | Required  | The input *CSV* file to be converted to *YAML*                                    |
| `--help`      | `-h`            | None             | Optional  | Shows a help message                                                              |
| `--step`      | `-s`            | None             | Optional  | Asks user for confirmation before each step of the script (used for *Debugging*)  |
| `--transpose` | `-t`            | None             | Optional  | Transposes the input *CSV* file "on-the-fly" before converting                    |
| `--version`   | `-v`            | None             | Optional  | Prints the version of the script                                                  |

## Output

The output will be a file with the same path and name as the input one, only with the `.yml` extension instead of the `.csv`.

Using our `sample.csv` file as an example, the output would be a file named `sample.yml` like this:

```yaml
computer:
  brand: HellLet PackYard
  motherboard:
    cpu:
      sockets: 1
      type: LGA 1151
    memory:
      banks: 4
      max: 32Gb
      type: DDR4
  price: US$499.99
```

___

That's all. Hope you enjoy!
