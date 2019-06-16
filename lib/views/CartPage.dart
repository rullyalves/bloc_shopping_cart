import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shoppingcart_bloc/blocs/CartBloc.dart';
import 'package:shoppingcart_bloc/components/CartItemWidget.dart';
import 'package:shoppingcart_bloc/model/CartItem.dart';

class CartPage extends StatefulWidget {
  _CartPage createState() => _CartPage();
}

class _CartPage extends State<CartPage> {
  CartBloc _cartBloc;

  @override
  void didChangeDependencies() {
    _cartBloc = BlocProvider.getBloc<CartBloc>();
    super.didChangeDependencies();
  }

  double deviceHeight;
  double deviceWidth;

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // faz com que o widget pegue todo o espaço disponível no eixo principal
          // sendo da linha ou coluna
          StreamBuilder(
            stream: _cartBloc.listOfItemsFlux,
            builder:
                (BuildContext context, AsyncSnapshot<List<CartItem>> snapshot) {
              // o ListView.builder é um widget que renderiza os filhos
              // de maneira preguiçosa , sob demanda , só renderiza
              // quantos o usuário puder ver
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: StreamBuilder(
                  stream: _cartBloc.listOfItemsFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<CartItem>> snapshot) {
                    // se não houverem dados válidos
                    // a função snapshot.hasData retorna false
                    // se snapshot.hasData for falso , mostra um widget para sinalizar
                    // que o carrinho está vazio , se não
                    // mostra o conteúdo da lista do carrinho

                    // a função isNotEmpty verifica se uma lista não é vazia
                    // ou seja , se uma lista possui mais de 0 elementos
                    // se uma lista possuir uma quantidade de elementos maior que 0
                    // retorna true
                    return snapshot.hasData && snapshot.data.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot?.data?.length,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return CartItemWidget(item: snapshot.data[index]);
                            },
                          )
                        : const Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "O carrinho está vazio :(",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 21),
                              ),
                            ),
                          );
                  },
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: ListTile(
                title: const Text(
                  "Cupom",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Use o seu cupom"),
                trailing: const Icon(Icons.add),
                leading: const Icon(Icons.card_membership),
              ),
            ),
          ),

// espaçamentos de 12 pixels na horizontal para manter o padrão
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 12, right: 12, bottom: 35),
            child: Card(
              elevation: 15,
              child: Container(
                width: deviceWidth,
                color: Colors.green,
                child: Column(
                  children: <Widget>[
                    Card(
                      color: Colors.green,
                      child: ListTile(
                        leading: Text(
                          "Desconto",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Text(
                          "R\$14.99",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // cards com elevação
                    Card(
                      color: Colors.green,
                      child: ListTile(
                        leading: Text(
                          "Total",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: StreamBuilder(
                          initialData: _cartBloc.totalValue,
                          stream: _cartBloc.totalFlux,
                          builder: (BuildContext context,
                              AsyncSnapshot<double> snapshot) {
                            double value = snapshot.data;
                            return Text(
                              "R\$ "
                              "${value.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35, left: 12, right: 12),
            child: Container(
              height: deviceHeight / 16,
              width: deviceWidth,
              child: FlatButton(
                color: Colors.black,
                onPressed: () async {},
                child: Text(
                  "Finalizar pedido",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Carrinho de compras",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }
}
