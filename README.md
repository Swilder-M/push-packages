# push-packages

```yaml
    - name: push to packagecloud
      uses: Swilder-M/push-packages@v1
      env:
        GIT_TOKEN: ${{ secrets.GIT_TOKEN }}
        PACKAGECLOUD_TOKEN: ${{ secrets.PACKAGECLOUD_TOKEN }}
      with:
        product: emqx
        version: 5.0.0
```