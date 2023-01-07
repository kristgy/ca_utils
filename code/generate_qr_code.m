function qr = generate_qr_code(ocr,due,bg)

% Generate QR kode using the matlab code from here:
% https://se.mathworks.com/matlabcentral/fileexchange/49808-qr-code-generator-1-1-based-on-zxing
% following the spec from here:
% https://www.qrkod.info/

% Partial solution for SWISH:
% sprintf('https://app.swish.nu/1/p/sw/?sw=%s&amt=%1.1f&cur=SEK&msg=%d',bg,due,ocr);
% according to: https://developer.swish.nu/documentation/guides/generate-qr-codes

%'{ "uqr": 1, "tp": 1, "nme": "Test AB", "cid": "1234", "iref": "1001", "idt": "20220926", "ddt": "20221026", "due": "50", "pt": "BG", "acc": "5536-7742" }'
message = ...
sprintf('{ "uqr": 1, "tp": 1, "iref": "%d", "due": "%1.2f", "pt": "BG", "acc": "%s" }',ocr,due,bg);
qr = qrcode_gen(message,'QuietZone',5); % Returns a matrix
return 
