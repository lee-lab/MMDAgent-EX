# mit

A tiny script to make and update content index file.

## Prerequisites

Perl is required to run.

## Usage

Execute the script at the top directory of your content.

- `mit.pl status` to see current status
- `mit.pl add FILES` to add the files to the content list
- `mit.pl add DIR` to add all files under the DIR to the content list
- `mit.pl add` to add all the files under current directory
- `mit.pl update` to update file sizes of the files listed in the content list

## Use case 

### Add all files and update

```shell
% cd content_topdir
% mit add .
% mit update
```
