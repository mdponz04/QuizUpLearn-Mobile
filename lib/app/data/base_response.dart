const baseUrl = 'http://10.0.2.2:5004/api';

class BaseResponse <T>{
  final bool isSuccess;
  final String message;
  final T? data;

  BaseResponse({required this.isSuccess, required this.message, required this.data});

  factory BaseResponse.success(T data) {
    return BaseResponse(isSuccess: true, message: 'Success', data: data);
  }

  factory BaseResponse.error(String message) {
    return BaseResponse(isSuccess: false, message: message, data: null);
  }
}