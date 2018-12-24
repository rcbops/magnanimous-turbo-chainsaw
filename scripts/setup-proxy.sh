#!/usr/bin/env bash

if [[ ! -z "${http_proxy}" ]]; then
  git config --global http.proxy ${http_proxy}
fi

if [[ ! -z "${http_proxy}" ]] || [[ ! -z "${https_proxy}" ]]; then
  git config --global https.proxy ${https_proxy:-${http_proxy}}
fi
