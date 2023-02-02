rm -rf builds && mkdir builds
pushd builds
for i in ../src/*.sol; do
    solcjs $i --base-path=../src/ --include-path=../lib/ --bin --abi --optimize --optimize-runs 99999  -o .
done
