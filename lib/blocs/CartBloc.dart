import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shoppingcart_bloc/model/CartItem.dart';
import 'package:shoppingcart_bloc/model/Product.dart';
import 'package:shoppingcart_bloc/model/ShoppingCart.dart';
import 'package:hydrated/hydrated.dart';

class CartBloc extends BlocBase {
  // inicializando o objeto do carrinho
  final _cart = new ShoppingCart();

  final _listOfItems = new HydratedSubject<List<CartItem>>(
    "shoppingCart",
    hydrate: (json) {
      if (json != null) {
        List<Map<String, dynamic>> maps =
            jsonDecode(json).cast<Map<String, dynamic>>();
        List<CartItem> parsed =
            maps.map<CartItem>((item) => CartItem.fromJson(item)).toList();
        return parsed;
      }
    },
    persist: (items) {
      if (items != null) {
        String encoded = jsonEncode(items);
        return encoded;
      }
    },
  );

  //final _listOfItems = new BehaviorSubject<List<CartItem>>();
  Observable<List<CartItem>> get listOfItemsFlux => _listOfItems?.stream;
  Sink<List<CartItem>> get listOfItemsEvent => _listOfItems?.sink;

  final _addController = new BehaviorSubject<Product>();
  Observable<Product> get addFlux => _addController?.stream;
  Sink<Product> get addEvent => _addController?.sink;

// controllers que irão fazer o trabalho de incrementar decrementar itens
  final _incrementController = new BehaviorSubject<CartItem>();
  Observable<CartItem> get incrementFlux => _incrementController?.stream;
  Sink<CartItem> get incrementEvent => _incrementController?.sink;

  final _decrementController = new BehaviorSubject<CartItem>();
  Observable<CartItem> get decrementFlux => _decrementController?.stream;
  Sink<CartItem> get decrementEvent => _decrementController?.sink;

// me liga no discord , se possível
  final _deleteController = new BehaviorSubject<Object>();
  Observable<Object> get deleteFlux => _deleteController?.stream;
  Sink<Object> get deleteEvent => _deleteController?.sink;

  final _numOfItems = new BehaviorSubject<int>();
  Observable<int> get numOfItemsFlux => _numOfItems?.stream;
  Sink<int> get numOfItemsEvent => _numOfItems?.sink;

  final _total = new BehaviorSubject<double>.seeded(0);
  Observable<double> get totalFlux => _total?.stream;
  Sink<double> get totalEvent => _total?.sink;
  double get totalValue => _total.value;

  Observable amountFlux;

// criando um construtor padrão
// quando o construtor é iniciado
// ele começa a ouvir todos os dados do controller "addController"
// ou seja , controller de adição de itens ao carrinho
  CartBloc() {
    amountFlux = Observable(incrementFlux)
        .mergeWith([decrementFlux]).asBroadcastStream();
    listOfItemsFlux.listen(_initPersist);
    _addController?.listen(_addUpdate);
    _deleteController?.listen(_deleteUpdate);
    _incrementController?.listen(_incrementUpdate);
    _decrementController?.listen(_decrementUpdate);
  }

// função para atualizar o carrinho
// recebe o produto como argumento
// cria um novo objeto de cart item com o produto dentro
// e adiciona o cart item recém criado ao carrinho
  void _addUpdate(Product newProduct) {
    // adicionando um item ao carrinho
    _cart.addItem(newProduct);
    // chamando a função de update para atualizarmos os outros controllers
    _update();
  }

// função que deleta um item do carrinho
// essa função recebe um Object , em dart todas as classes herdam da classe object
// isso significa que podemos receber qualquer instância de classe aqui
  void _deleteUpdate(Object item) {
    // em seguida , verificamos se o Object é uma instância de produto
    // se for , nós criamos um cartItem com o produto dentro dele e o deletamos
    // se não , nós só fazemos a deleção padrão dele , pois já está no formato ideal para ser deletado
    // do carrinho de compras
    if (item is Product) {
      CartItem cartItem = new CartItem(item);
      _cart?.deleteItem(cartItem);
    } else if (item is CartItem) {
      // deletando item do carrinho
      _cart?.deleteItem(item);
    }

    // atualizando os outros controllers que carregam as informações
    // do carrinho , como : total de itens , valor total da soma dos itens
    // lista de itens que estão no carrinho etc
    _update();
  }

  void _incrementUpdate(CartItem item) {
    item.incrementAmount();
    print(item.amount);
    _updateAmount();
  }

  void _decrementUpdate(CartItem item) {
    if (item.amount <= 1) {
      _deleteUpdate(item);
    } else {
      item.decrementAmount();
    }
    print(item.amount);
    _updateAmount();
  }

  void _initPersist(List<CartItem> items) {
    if (items.isNotEmpty) {
      _cart.items = items;
      totalEvent.add(_cart.total);
    }
  }

// função para atualizar os outros controllers
// essa função atualiza a camada visual da aplicação sempre que é chamada
// fazendo o controller de lista de itens do carrinho receber o valor da lista
// de itens do carrinho

// dentre outras atualizações , como número de itens e valor total dos itens
// contidos no carrinho

  void _update() {
    listOfItemsEvent?.add(_cart.items);
    numOfItemsEvent?.add(_cart.numOfItems);
    totalEvent?.add(_cart.total);
  }

  void _updateAmount() {
    numOfItemsEvent?.add(_cart.numOfItems);
    totalEvent?.add(_cart.total);
    listOfItemsEvent.add(_cart.items);
  }

  @override
  void dispose() {
    super.dispose();
    _addController?.close();
    _deleteController?.close();
    _numOfItems?.close();
    _total?.close();
    _listOfItems?.close();
  }
}
