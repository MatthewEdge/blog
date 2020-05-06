#!/bin/sh
hugo
aws s3 sync --delete ./public/ s3://blog.medgelabs.io
