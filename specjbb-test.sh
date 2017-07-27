#!/bin/bash

cp specjbb2015_D05.props config/specjbb2015.props

# 1 group test
./run_multi_1groupok.sh

# 4 group test
./run_multi_4groupok.sh
