import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        child: Column(
          children: [
            Expanded(
              child: LoanCalculatorScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanCalculatorScreen extends StatefulWidget {
  @override
  _LoanCalculatorScreenState createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  double _numberOfMonths = 1;
  final TextEditingController _percentController = TextEditingController();
  double _monthlyPayment = 0.0;

  void _calculateMonthlyPayment() {
    if (_formKey.currentState!.validate()) {
      double amount = double.tryParse(_amountController.text) ?? 0.0;
      double annualInterestRate = double.tryParse(_percentController.text) ?? 0.0;
      double monthlyInterestRate = (annualInterestRate / 100) / 12;
      double totalMonths = _numberOfMonths;

      if (monthlyInterestRate > 0) {
        double numerator = amount * monthlyInterestRate * pow(1 + monthlyInterestRate, totalMonths);
        double denominator = pow(1 + monthlyInterestRate, totalMonths) - 1;
        setState(() {
          _monthlyPayment = numerator / denominator;
        });
      } else {
        setState(() {
          _monthlyPayment = amount / totalMonths;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loan calculator',
                      style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 32),

                    Field(
                      header: 'Enter amount',
                      controller: _amountController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Field(
                      header: 'Enter number of months',
                      child: SliderField(
                        value: _numberOfMonths,
                        onChanged: (double value) {
                          setState(() {
                            _numberOfMonths = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Field(
                      header: 'Enter % per year',
                      controller: _percentController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a percentage';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(30.0),
                          color: CupertinoColors.systemGrey6,
                          child: Text(
                            'You will pay the\napproximate amount\nmonthly:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${_monthlyPayment.toStringAsFixed(2)}€',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.activeBlue),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    Container(
                      width: 500,
                      child: CupertinoButton.filled(
                        child: Text('Calculate'),
                        onPressed: _calculateMonthlyPayment,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Field extends StatelessWidget {
  final String header;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? child;

  Field({required this.header, this.controller, this.child, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        child ??
            CupertinoTextField(
              controller: controller,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.inactiveGray),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(12.0),
            ),
        SizedBox(height: 8),
        if (validator != null)
          Text(
            validator!(controller?.text) ?? '',
            style: TextStyle(
              color: CupertinoColors.systemRed,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class SliderField extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  SliderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              child: CupertinoSlider(
                value: value,
                min: 1,
                max: 60,
                divisions: 59,
                onChanged: onChanged,
              ),
            ),
            Positioned(
              left: ((value - 1) / 59) * MediaQuery.of(context).size.width - 10,
              bottom: 15,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '60 months',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
