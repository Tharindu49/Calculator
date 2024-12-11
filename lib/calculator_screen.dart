import 'package:flutter/material.dart';
import 'package:calculator/button_values.dart'; // Ensure Btn class is defined here
import 'dart:math';
import 'package:math_expressions/math_expressions.dart'; // Import the math_expressions package

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // . 0-9
  String operand = ""; // + - * / etc
  String number2 = ""; // . 0-9
  List<String> history = []; // To store the history of calculations

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modern Calculator',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Output - top part
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(40)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10)
                  ],
                ),
                child: Text(
                  "$number1$operand$number2".isEmpty
                      ? "0"
                      : "$number1$operand$number2",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      screenSize.width / (4 * (screenSize.width / 5)),
                ),
                itemCount: Btn.buttonValues.length,
                itemBuilder: (context, index) {
                  final value = Btn.buttonValues[index];
                  return buildButton(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Material(
      color: getBtnColor(value),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 8,
      child: InkWell(
        onTap: () => onBtnTap(value),
        onHighlightChanged: (highlighted) {
          setState(() {});
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
      ),
    );
  }

  Color getBtnColor(String value) {
    return [Btn.del, Btn.clr].contains(value)
        ? const Color(0xFFf44136) // Red for delete and clear
        : [
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.calculate,
            Btn.power,
            Btn.factorial,
            Btn.openParenthesis,
            Btn.closeParenthesis,
          ].contains(value)
            ? const Color(0xFF4c4f66) // Dark gray for operators
            : const Color(0xFF303030); // Darker gray for numbers
  }

  void appendValue(String value) {
    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operand.isNotEmpty && number2.isNotEmpty) {
        operand = value; // Switch operand
      }
    } else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0."; // Handle first dot input
      }
      number1 += value;
    } else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        value = "0.";
      }
      number2 += value;
    }
    setState(() {});
  }

  void calculateFactorial() {
    if (number1.isEmpty || operand.isNotEmpty || number2.isNotEmpty) {
      return;
    }

    try {
      int n = int.parse(number1);
      if (n < 0) {
        setState(() {
          number1 = "Error"; // Factorial not defined for negative numbers
        });
        return;
      }

      int result = factorial(n);
      setState(() {
        number1 = result.toString();
        operand = "";
        number2 = "";
      });
    } catch (e) {
      setState(() {
        number1 = "Error";
      });
    }
  }

  int factorial(int n) {
    if (n == 0) return 1;
    return n * factorial(n - 1);
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    if (value == Btn.sqrt) {
      calculateSquareRoot();
      return;
    }

    if (value == Btn.factorial) {
      calculateFactorial();
      return;
    }

    if (value == Btn.power) {
      appendValue(value);
      return;
    }

    if (value == Btn.openParenthesis || value == Btn.closeParenthesis) {
      appendParentheses(value); // Handle parentheses correctly
      return;
    }

    if (['+', '-', '×', '÷'].contains(value)) {
      if (number1.isNotEmpty && operand.isEmpty) {
        operand = value;
      } else if (number2.isNotEmpty) {
        calculate();
        operand = value;
        number2 = '';
      }
    } else if (value == '^') {
      // Handle the exponentiation operator
      appendValue('^');
    } else {
      appendValue(value);
    }
  }

  void appendParentheses(String value) {
    if (value == Btn.openParenthesis) {
      if (number1.isNotEmpty && operand.isEmpty) {
        number1 += "*";
      }
      number1 += "(";
    } else if (value == Btn.closeParenthesis) {
      number1 += ")";
    }
    setState(() {});
  }

  void calculate() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;

    String expression = "$number1$operand$number2";

    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    // Fix implicit multiplication with parentheses
    expression = expression.replaceAll(RegExp(r'(\d)(\()'), r'$1*$2');

    if (expression.startsWith('(')) {
      expression = '0$expression';
    }

    // Handle ^ as ** for exponentiation
    expression = expression.replaceAll('^', '**');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        number1 = result.toStringAsPrecision(10);
        operand = "";
        number2 = "";
      });

      history.insert(0, "$expression = $result");
    } catch (e) {
      setState(() {
        number1 = "Error";
      });
    }
  }

  void delete() {
    if (number2.isNotEmpty) {
      number2 = number2.substring(0, number2.length - 1);
    } else if (operand.isNotEmpty) {
      operand = operand.substring(0, operand.length - 1);
    } else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }
    setState(() {});
  }

  void clearAll() {
    number1 = "";
    operand = "";
    number2 = "";
    setState(() {});
  }

  void convertToPercentage() {
    if (number2.isEmpty && operand.isEmpty && number1.isNotEmpty) {
      setState(() {
        number1 = (double.parse(number1) / 100).toString();
      });
    }
  }

  void calculateSquareRoot() {
    if (number1.isNotEmpty && operand.isEmpty && number2.isEmpty) {
      double num = double.parse(number1);
      if (num < 0) {
        setState(() {
          number1 = "Error"; // Handle negative number square roots
        });
      } else {
        setState(() {
          number1 = (sqrt(num)).toString();
        });
      }
    }
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Calculation History"),
          content: SizedBox(
            height: 400,
            width: 300,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(history[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
