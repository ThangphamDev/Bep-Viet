import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import * as querystring from 'qs';

@Injectable()
export class VNPayService {
  private readonly logger = new Logger(VNPayService.name);

  private readonly vnpTmnCode: string;
  private readonly vnpHashSecret: string;
  private readonly vnpUrl: string;
  private readonly vnpApiUrl: string;
  private readonly vnpReturnUrl: string;

  constructor(private config: ConfigService) {
    this.vnpTmnCode = (this.config.get('VNPAY_TMN_CODE') ?? '').trim();
    this.vnpHashSecret = (this.config.get('VNPAY_HASH_SECRET') ?? '').trim();
    this.vnpUrl = (this.config.get('VNPAY_URL') ?? 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html').trim();
    this.vnpApiUrl = (this.config.get('VNPAY_API_URL') ?? 'https://sandbox.vnpayment.vn/merchant_webapi/api/transaction').trim();

    const baseUrl = (this.config.get('BASE_URL') ?? 'https://gullably-nonpsychological-leisha.ngrok-free.dev').trim();
    this.vnpReturnUrl = `${baseUrl}/api/payments/vnpay/return`;

    this.logger.log(`VNPay TMN: ${this.vnpTmnCode}, Return: ${this.vnpReturnUrl}`);
  }

  /** Tạo link thanh toán */
  createPaymentUrl(
    orderId: string,
    amountVnd: number,
    orderInfo: string,
    ipAddr: string,
    bankCode?: string
  ): string {
    const now = new Date();
    const createDate = this.formatDateTime(now);
    const expireDate = this.formatDateTime(new Date(now.getTime() + 15 * 60 * 1000));

    const rawParams: Record<string, string | number> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: this.vnpTmnCode,
      vnp_Locale: 'vn',
      vnp_CurrCode: 'VND',
      vnp_TxnRef: orderId,
      vnp_OrderInfo: orderInfo,
      vnp_OrderType: 'other',
      vnp_Amount: Math.round(amountVnd) * 100, // integer × 100
      vnp_ReturnUrl: this.vnpReturnUrl,
      vnp_IpAddr: ipAddr || '0.0.0.0',
      vnp_CreateDate: createDate,
      vnp_ExpireDate: expireDate,
    };
    if (bankCode) rawParams['vnp_BankCode'] = bankCode;

    // 1) Encode value trước khi ký
    const encParams = this.encodeParams(rawParams);

    // 2) Sort theo key
    const sortedEnc = this.sortObject(encParams);

    // 3) Ký SHA512 trên CHUỖI ĐÃ ENCODE
    const signData = querystring.stringify(sortedEnc, { encode: false });
    const vnp_SecureHash = crypto.createHmac('sha512', this.vnpHashSecret)
      .update(Buffer.from(signData, 'utf-8'))
      .digest('hex');

    // 4) Dùng chính bản đã encode để gửi đi
    const finalParams = { ...sortedEnc, vnp_SecureHash };
    const paymentUrl = this.vnpUrl + '?' + querystring.stringify(finalParams, { encode: false });

    this.logger.debug('VNPay signData: ' + signData);
    this.logger.debug('VNPay url: ' + paymentUrl);

    return paymentUrl;
  }

  /** Xác thực return/callback */
  verifyReturnUrl(vnpParamsRaw: Record<string, string>) {
    const secureHash = vnpParamsRaw['vnp_SecureHash'] || '';
    // bỏ 2 field không tham gia ký
    const { vnp_SecureHash, vnp_SecureHashType, ...rest } = vnpParamsRaw;

    // Encode value giống hệt lúc tạo URL
    const encParams = this.encodeParams(rest);
    const sortedEnc = this.sortObject(encParams);

    const signData = querystring.stringify(sortedEnc, { encode: false });
    const checkHash = crypto.createHmac('sha512', this.vnpHashSecret)
      .update(Buffer.from(signData, 'utf-8'))
      .digest('hex');

    const isValid = checkHash === secureHash;
    const responseCode = rest['vnp_ResponseCode'] || '99';
    const orderId = rest['vnp_TxnRef'] || '';
    const amount = rest['vnp_Amount'] ? parseInt(rest['vnp_Amount'], 10) / 100 : 0;

    return {
      isValid,
      orderId,
      amount,
      responseCode,
      message: this.getResponseMessage(responseCode),
      transactionNo: rest['vnp_TransactionNo'],
      bankCode: rest['vnp_BankCode'],
      payDate: rest['vnp_PayDate'],
    };
  }

  /** Query giao dịch (tham khảo) */
  async queryTransaction(orderId: string, transDate: string) {
    const now = new Date();
    const base: Record<string, string> = {
      vnp_RequestId: this.formatDateTime(now),
      vnp_Version: '2.1.0',
      vnp_Command: 'querydr',
      vnp_TmnCode: this.vnpTmnCode,
      vnp_TxnRef: orderId,
      vnp_OrderInfo: `Query for ${orderId}`,
      vnp_TransactionDate: transDate,
      vnp_CreateDate: this.formatDateTime(now),
      vnp_IpAddr: '127.0.0.1',
    };

    const enc = this.encodeParams(base);
    const sorted = this.sortObject(enc);
    const signData = querystring.stringify(sorted, { encode: false });
    const vnp_SecureHash = crypto.createHmac('sha512', this.vnpHashSecret)
      .update(Buffer.from(signData, 'utf-8'))
      .digest('hex');

    return { ...sorted, vnp_SecureHash };
  }

  // ================= helpers =================

  /** Encode value theo RFC3986; thay %20 -> + để khớp phía VNPay */
  private encodeParams(obj: Record<string, any>) {
    const out: Record<string, string> = {};
    Object.keys(obj).forEach((k) => {
      const val = String(obj[k] ?? '');
      out[k] = encodeURIComponent(val).replace(/%20/g, '+');
    });
    return out;
  }

  private sortObject<T extends Record<string, any>>(obj: T): T {
    const sorted: any = {};
    Object.keys(obj).sort().forEach((k) => (sorted[k] = obj[k]));
    return sorted;
  }

  /** YYYYMMDDHHmmss */
  private formatDateTime(d: Date) {
    const p = (n: number) => String(n).padStart(2, '0');
    return `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`;
  }

  private getResponseMessage(code: string) {
    const map: Record<string, string> = {
      '00': 'Giao dịch thành công',
      '07': 'Trừ tiền thành công nhưng giao dịch nghi ngờ.',
      '09': 'Tài khoản/chưa đăng ký InternetBanking.',
      '10': 'Xác thực sai quá 3 lần.',
      '11': 'Hết hạn chờ thanh toán.',
      '12': 'Thẻ/Tài khoản bị khóa.',
      '13': 'Sai OTP.',
      '24': 'Khách hàng hủy giao dịch.',
      '51': 'Không đủ số dư.',
      '65': 'Vượt hạn mức trong ngày.',
      '75': 'Ngân hàng bảo trì.',
      '79': 'Nhập sai mật khẩu thanh toán quá số lần.',
      '99': 'Lỗi khác.',
    };
    return map[code] || 'Giao dịch thất bại';
  }
}
