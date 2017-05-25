if [ $# -eq 1 ]; then
    echo "A tag and token argument is needed!(ex: ./release.sh 1.2.3 xxxxxxx)"
    exit 1
fi
lib_name="license-plist"
tag=$1
token=$2
export GITHUB_TOKEN=$token
echo "Tag: '${tag}'"
echo "Token: '${token}'"
filename="${tag}.tar.gz"
echo "Filename: '${filename}'"

# tag
git tag $tag
git push origin $tag

curl -LOk "https://github.com/mono0926/LicensePlist/archive/${filename}"
sha256=$(shasum -a 256 $filename | cut -d ' ' -f 1)
rm $filename

formula_path="$lib_name.rb"
formula_url="https://api.github.com/repos/mono0926/homebrew-$lib_name/contents/$formula_path"
sha=`curl GET $formula_url \
	| jq -r '.sha'`
echo "sha: \n$sha"
content_encoded=`cat formula.rb.tmpl | sed -e "s/{{TAG}}/$tag/" | sed -e "s/{{SHA256}}/$sha256/" | openssl enc -e -base64 | tr -d '\n '`
echo "content_encoded: \n$content_encoded"

commit_message="Update version to $tag"

curl -i -X PUT $formula_url \
   -H "Content-Type:application/json" \
   -H "Authorization:token $token" \
   -d \
"{
  \"path\":\"$formula_path\",
  \"sha\":\"$sha\",
  \"content\":\"$content_encoded\",
  \"message\":\"$commit_message\"
}"

brew upgrade $lib_name
zip $lib_name.zip /usr/local/bin/$lib_name

github-release release \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag

github-release upload \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag \
    --name "$lib_name.zip" \
    --file $lib_name.zip

rm $lib_name.zip 
