#!/usr/bin/env bash

KEY='ZgbkEzSP1HEeEtUlAug-9Z3OTUqUDDb89';

API_URL='https://localise.biz/api/export/locale/';
TAG='ios-zoom';
ORDER='order=id'

echo 'Downloading localizations...'
curl -s -o 'FaceTecSDK.framework/en.lproj/FaceTec.strings' "${API_URL}en.strings?filter=$TAG&$ORDER&key=$KEY"
curl -s -o 'FaceTecSDK.framework/ru.lproj/FaceTec.strings' "${API_URL}ru.strings?filter=$TAG&$ORDER&key=$KEY"
curl -s -o 'FaceTecSDK.framework/kk.lproj/FaceTec.strings' "${API_URL}kk.strings?filter=$TAG&$ORDER&key=$KEY"
echo 'Downloading ✅'
