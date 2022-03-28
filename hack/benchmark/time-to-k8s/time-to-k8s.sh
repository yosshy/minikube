#!/bin/bash

# Copyright 2021 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

install_kind() {
	curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin/kind
}

install_k3d() {
	curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
}

install_minikube() {
	make
	sudo install ./out/minikube /usr/local/bin/minikube
}

run_benchmark() {
	( cd ./hack/benchmark/time-to-k8s/time-to-k8s-repo/ &&
		git submodule update --init &&
		go run . --config local-kubernetes.yaml --iterations 10 --output output.csv )
}


# create page and generate chart inside the code
create_page() {
	go run ./hack/benchmark/time-to-k8s/*.go --csv ./hack/benchmark/time-to-k8s/time-to-k8s-repo/output.csv --image ./site/static/images/benchmarks/timeToK8s/"$1" --page ./site/content/en/docs/benchmarks/timeToK8s/"$1".md
}

cleanup() {
	rm ./hack/benchmark/time-to-k8s/time-to-k8s-repo/output.csv
}

install_kind
install_k3d
install_minikube

VERSION=$(minikube version --short)
run_benchmark
create_page "$VERSION"
cleanup
