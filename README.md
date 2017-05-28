# tinypng-api-utils
Api utilities for [tinypng](https://tinypng.com/developers).

Get your Api key here: https://tinypng.com/dashboard/developers


## optimize
Commandline script to optimize images via tinypng api.
Usage:

```
optimize -i INPUT_FILE [-o OUTPUT_FILE] [-key APIKEY]
  -i:   Path to image file with extension png, gif, jpg or jpeg
  -o:   Path to output file (optional, input_file is overwritten by default)
  -key: Api key (optional, content of a file named API_KEY is used as default)
```
