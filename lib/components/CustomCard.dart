import 'dart:async';
import 'dart:math';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shoppingcart_bloc/blocs/CardItemBloc.dart';
import 'package:shoppingcart_bloc/blocs/CartBloc.dart';
import 'package:shoppingcart_bloc/model/Product.dart';

class CustomCard extends StatefulWidget {
  CustomCard(
      {Key key,
      this.function,
      this.item,})
      : super(key: key);

  final VoidCallback function;
  final Product item;

  _CustomCard createState() => _CustomCard();
}

class _CustomCard extends State<CustomCard> {
  // declarando o cardItemBloc como atributo privado
  // ou seja , está encapsulado e não é visível em outros lugares
  CartBloc _cartBloc;
  CardItemBloc _cardItemBloc;
  // StreamSubscription _favoriteSubscription;
  StreamSubscription _subscription;

  @override
  void initState() {
    _cardItemBloc = new CardItemBloc(widget.item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription =
          _cartBloc?.listOfItemsFlux?.listen(_cardItemBloc?.itensInCartEvent?.add);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
   _cartBloc = BlocProvider.getBloc<CartBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cardItemBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: GestureDetector(
        onTap:widget.function,
        child: Container(
          child: Column(
            children: <Widget>[
              // colocar HERO
              Hero(
                tag: widget?.item?.id ?? "${Random(1).nextInt(300)}",
                child:Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.31,
                        child: CachedNetworkImage(
                            imageUrl:
                                "http://images.guiadohamburguer.com/wp-content/uploads/2015/11/13-hamburguer-costela-oburguer-foodtruck.jpg",
                            fit: BoxFit.fill,
                            placeholder: (BuildContext context, String text) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            errorWidget: (BuildContext context, String text,
                                Object e) {
                              return Center(
                                child: Text(
                                  "Erro ao carregar imagem :(",
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 21),
                                ),
                              );
                            }),
                      )
                
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: StreamBuilder(
                      initialData: _cardItemBloc.isInCartFlux.value,
                      stream: _cardItemBloc.isInCartFlux,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        print(snapshot.data);
                        return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: snapshot.data
                                        ? const Icon(
                                            Icons.remove_shopping_cart,
                                            color: Colors.red,
                                            size: 30,
                                          )
                                        : const Icon(
                                            Icons.add_shopping_cart,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                    onPressed: () {
                                      if (snapshot.data) {
                                        _cartBloc.deleteEvent.add(widget.item);
                                      } else {
                                        _cartBloc.addEvent.add(widget.item);
                                      }
                                    },
                                  ),
                                  Container(
                                    width: 80,
                                    child: snapshot.data
                                        ? const Text(
                                            "Remover do carrinho",
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text(
                                            "Adicionar ao carrinho",
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                                ],
                              );
                
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          widget?.item?.name ?? "ALGUMA COISA",
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "R\$ ${widget?.item?.price}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.white,
                          Colors.white,
                          Color(
                            0xFFAAAAAA,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        15.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(
                          10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(
                            const Radius.circular(
                              15.0,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}