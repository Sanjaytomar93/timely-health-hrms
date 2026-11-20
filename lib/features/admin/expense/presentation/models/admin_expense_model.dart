class AdminExpenseItem {
  const AdminExpenseItem({
    required this.id,
    required this.name,
    required this.code,
    required this.designation,
    required this.initial,
    required this.status, // Pending or Paid
    required this.visits,
    required this.distance,
    required this.reimbursement,
    this.isPaid = false,
  });

  final String id;
  final String name;
  final String code;
  final String designation;
  final String initial;
  final String status;
  final String visits;
  final String distance;
  final String reimbursement;
  final bool isPaid;

  static List<AdminExpenseItem> sampleList() {
    return const [
      AdminExpenseItem(
        id: 'exp_1',
        name: 'K Akhil Kumar',
        code: 'TH008',
        designation: 'PHLEBOTOMIST',
        initial: 'K',
        status: 'Pending',
        visits: '32 Visits',
        distance: '393.9 KM',
        reimbursement: '₹1,575.6',
      ),
      AdminExpenseItem(
        id: 'exp_2',
        name: 'srikanth kuppala',
        code: 'TH062',
        designation: 'PHLEBOTOMIST',
        initial: 'S',
        status: 'Pending',
        visits: '10 Visits',
        distance: '166.2 KM',
        reimbursement: '₹664.8',
      ),
      AdminExpenseItem(
        id: 'exp_3',
        name: 'Kathavath Murali',
        code: 'TH068',
        designation: 'PHLEBOTOMIST',
        initial: 'K',
        status: 'Pending',
        visits: '8 Visits',
        distance: '152 KM',
        reimbursement: '₹608',
      ),
      AdminExpenseItem(
        id: 'exp_4',
        name: 'Vanjari nikhil kumar',
        code: 'TH860',
        designation: 'PHARMACIST',
        initial: 'V',
        status: 'Pending',
        visits: '10 Visits',
        distance: '80.5 KM',
        reimbursement: '₹322',
      ),
      AdminExpenseItem(
        id: 'exp_5',
        name: 'JATTOTH ANIL',
        code: 'TH047',
        designation: 'SR. MARKETING EXEC',
        initial: 'J',
        status: 'Pending',
        visits: '4 Visits',
        distance: '50.3 KM',
        reimbursement: '₹201.2',
      ),
      AdminExpenseItem(
        id: 'exp_6',
        name: 'manager Kumar',
        code: 'TH029',
        designation: 'MANGER',
        initial: 'M',
        status: 'Pending',
        visits: '2 Visits',
        distance: '40 KM',
        reimbursement: '₹160',
      ),
      AdminExpenseItem(
        id: 'exp_7',
        name: 'Saquiba Wasi',
        code: 'TH011',
        designation: 'MERN STACK DEV',
        initial: 'S',
        status: 'Paid',
        visits: '1 Visits',
        distance: '37 KM',
        reimbursement: '₹148',
        isPaid: true,
      ),
      AdminExpenseItem(
        id: 'exp_8',
        name: 'KARDAM KUMAR',
        code: 'TH012',
        designation: 'WEB DEVELOPER',
        initial: 'K',
        status: 'Pending',
        visits: '1 Visits',
        distance: '11 KM',
        reimbursement: '₹44',
      ),
      AdminExpenseItem(
        id: 'exp_9',
        name: 'Sanjay Tomar',
        code: 'TH063',
        designation: 'FLUTTER DEV',
        initial: 'S',
        status: 'Pending',
        visits: '1 Visits',
        distance: '10 KM',
        reimbursement: '₹40',
      ),
    ];
  }
}
