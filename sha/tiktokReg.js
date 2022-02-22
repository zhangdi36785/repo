var url = $request.url;

if (url.indexOf("/passport/user/check_email_registered") != -1) {
    var body = $response.body;

    var obj = JSON.parse(body);
    let error_code = obj.data.error_code;
    if (error_code==1105){
        body = "{\"data\":{\"is_registered\":0},\"message\":\"success\"}"

    } 
    $done({body});
}