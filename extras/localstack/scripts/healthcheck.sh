#!/bin/bash

set -e
curl -s http://localhost:${EDGE_PORT}/health | grep '"version":'
