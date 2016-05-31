#!/bin/bash -eux

cat /tmp/public.pub | tee -a ~/.ssh/authorized_keys
