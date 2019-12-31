import 'package:flutter/material.dart';
import 'package:harco_app/models/unit.dart';

class DropdownUnit extends StatelessWidget {
  const DropdownUnit(
      {Key key,
      @required addTransactionBloc,
      @required FocusNode nodeUnit,
      @required this.controllerUnit})
      : _addTransactionBloc = addTransactionBloc,
        _nodeUnit = nodeUnit,
        super(key: key);

  final _addTransactionBloc;
  final FocusNode _nodeUnit;
  final TextEditingController controllerUnit;

  Future dialogCreateUnit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah satuan'),
        content: TextField(
          controller: controllerUnit,
          decoration: InputDecoration(labelText: 'contoh : kg'),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Tambah'),
            onPressed: () {
              Unit unit = Unit(
                controllerUnit.text.toLowerCase(),
                DateTime.now().millisecondsSinceEpoch.toString(),
              );
              _addTransactionBloc.createUnit(unit);
              _addTransactionBloc.subjectUnitValue.sink.add(unit.name);
              controllerUnit.text = '';

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        StreamBuilder<List<Unit>>(
            stream: _addTransactionBloc.unitListStream,
            initialData: List(),
            builder: (context, snapshot_1) {
              if (snapshot_1.hasData) {
                List<Unit> units = snapshot_1.data;

                return Expanded(
                  flex: 7,
                  child: StreamBuilder<String>(
                      stream: _addTransactionBloc.unitStream,
                      initialData: null,
                      builder: (context, snapshot_2) {
                        return DropdownButton(
                          focusNode: _nodeUnit,
                          value: snapshot_2.data,
                          isExpanded: true,
                          hint: Text('Pilih satuan'),
                          onChanged: (val) {
                            _addTransactionBloc.subjectUnitValue.sink.add(val);
                          },
                          items: units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit.name,
                                  child: Text(unit.name),
                                ),
                              )
                              .toList(),
                        );
                      }),
                );
              }
              return Container();
            }),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Material(
            shape: Border.all(color: Theme.of(context).colorScheme.surface),
            elevation: 2,
            child: InkWell(
              child: Container(
                  padding: EdgeInsets.all(4.0), child: Icon(Icons.add)),
              onTap: () {
                dialogCreateUnit(context);
              },
            ),
          ),
        )
      ],
    );
  }
}
