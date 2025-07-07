
import '../../../utils/constants/db_constants.dart';
import '../../../utils/data/state_iso_code_map.dart';
import '../../../utils/formatters/formatters.dart';
import '../../../utils/validators/validation.dart';

class AddressModel {
  String? id;
  String? firstName;
  String? lastName;
  String? phone ;
  String? email;
  String? address1;
  String? address2;
  String? company;
  String? city;
  String? state;
  String? pincode;
  String? country;
  DateTime? dateCreated;
  DateTime? dateModified;
  bool? selectedAddress;

  AddressModel({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address1,
    this.address2,
    this.company,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.dateCreated,
    this.dateModified,
    this.selectedAddress = true,
  });

  String get formattedPhoneNo => AppFormatter.formatPhoneNumber(phone!);
  String get name => '$firstName $lastName';

  static AddressModel empty() => AddressModel(id: '');

  // Method to check which fields are missing or empty
  List<String> validateFields() {
    List<String> missingFields = [];

    String? phoneError = Validator.validatePhoneNumber(phone);
    String? emailError = Validator.validateEmail(email);
    String? pincodeError = Validator.validatePinCode(pincode);

    if (firstName?.isEmpty ?? true) missingFields.add('First Name is missing');
    if (address1?.isEmpty ?? true) missingFields.add('Address is missing');
    if (city?.isEmpty ?? true) missingFields.add('City is missing');
    if (state?.isEmpty ?? true) missingFields.add('State is missing');
    if (country?.isEmpty ?? true) missingFields.add('Country is missing');
    if (phoneError != null) {
      missingFields.add(phoneError);
    }
    if (emailError != null) {
      missingFields.add(emailError);
    }
    if (pincodeError != null) {
      missingFields.add(pincodeError);
    }
    return missingFields;
  }



  Map<String, dynamic> toJson() {
    return {
      AddressFieldName.id: id,
      AddressFieldName.firstName: firstName,
      AddressFieldName.lastName: lastName,
      AddressFieldName.phone: phone,
      AddressFieldName.email: email,
      AddressFieldName.address1: address1,
      AddressFieldName.address2: address2,
      AddressFieldName.city: city,
      AddressFieldName.state: state,
      AddressFieldName.pincode: pincode,
      AddressFieldName.country: country,
      AddressFieldName.dateCreated: dateCreated,
      AddressFieldName.dateModified: dateModified,
      AddressFieldName.selectedAddress: selectedAddress,
    };
  }
  Map<String, dynamic> toJsonForWoo() {
    return {
      AddressFieldName.firstName: firstName ?? '',
      AddressFieldName.lastName: lastName ?? '',
      AddressFieldName.phone: phone ?? '',
      AddressFieldName.email: email ?? 'example@gmail.com',
      AddressFieldName.address1: address1 ?? '',
      AddressFieldName.address2: address2 ?? '',
      AddressFieldName.city: city ?? '',
      AddressFieldName.state: state ?? '',
      AddressFieldName.pincode: pincode ?? '',
      AddressFieldName.country: country ?? '',
    };
  }
  factory AddressModel.fromJson(Map<String, dynamic> data) {
    return AddressModel(
      id: data[AddressFieldName.id] ?? '',
      firstName: data[AddressFieldName.firstName]?? '',
      lastName: data[AddressFieldName.lastName] ?? '',
      phone: data[AddressFieldName.phone] ?? '',
      email: data[AddressFieldName.email] ?? '',
      address1: data[AddressFieldName.address1] ?? '',
      address2: data[AddressFieldName.address2] ?? '',
      company: data[AddressFieldName.company] ?? '',
      city: data[AddressFieldName.city] ?? '',
      pincode: data[AddressFieldName.pincode] ?? '',
      state: StateData.getStateFromISOCode(data[AddressFieldName.state] ?? ''),
      country: CountryData.getCountryFromISOCode(data[AddressFieldName.country].isEmpty ? 'IN' : data[AddressFieldName.country]),
    );
  }

  @override
  String toString() {
    return '$address1, $address2, $city, $state, $pincode, $country';
  }

  String completeAddress() {
    return '$name, $email, $phone, $address1, $address2, $city, $state, $pincode, $country';
  }
}