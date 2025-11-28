#!/usr/bin/env bash

shellcheck --shell=bash --external-sources \
	bin/* --source-path=lib/ \
	lib/*

shfmt --language-dialect bash --diff \
	bin/* \
	lib/*
