class CreatePatientParams {
  const CreatePatientParams({
    required this.salutation,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.campId,
  });

  final String salutation;
  final String name;
  final String age;
  final String gender;
  final String contact;
  final String address;
  final String campId;
}
