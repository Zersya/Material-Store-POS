import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/expense.dart';
import 'package:harco_app/services/expense_service.dart';
import 'package:harco_app/utils/enum.dart';

class ExpenseBloc extends BaseReponseBloc<FormState>{
  ExpenseService _expenseService = GetIt.I<ExpenseService>();

  Future createExpense(Expense expense) async {
    this.subjectState.sink.add(FormState.LOADING);
    MyResponse response = await _expenseService.createExpense(expense);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }
}