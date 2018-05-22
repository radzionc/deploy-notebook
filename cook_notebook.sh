mkdir package

jupyter nbconvert --to script main.ipynb
mv main.py ./package/main.py

while read lib; do
  pip install $lib -t ./package
done <libs.txt

chmod -R +x ./package/
cd package
echo 'backend : agg' > matplotlibrc
zip -r ../function.zip *

cd ..
rm -rf package