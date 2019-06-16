import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shoppingcart_bloc/model/CartItem.dart';
import 'package:shoppingcart_bloc/model/Product.dart';

class CardItemBloc {

  StreamSubscription _subscription;
  // inicializando a stream da lista de itens presente no carrinho
  // esse controller existe somente para pegar os dados da stream de itens
  // que existe no bloc do carrinho , basicamente vamos utilizar a mesma stream de dados
  // nos dois blocs , assim os dois vão conversar entre si
  final _itensInCart = new BehaviorSubject<List<CartItem>>();
  ValueObservable<List<CartItem>> get itensInCartFlux => _itensInCart.stream;
  Sink<List<CartItem>> get itensInCartEvent => _itensInCart.sink;

// esse stream controller exibe um booleano
// esse booleano é true se o item estiver dentro do carrinho
// e false se não estiver
  final _isInCart = new BehaviorSubject<bool>.seeded(false);
  ValueObservable<bool> get isInCartFlux => _isInCart.stream;
  Sink<bool> get isInCartEvent => _isInCart.sink;


// criando um construtor para o cardItemBloc
// esse construtor recebe uma instância de produto
// e ao ser inicializando , verifica se esse produto está dentro
// da lista de itens do carrinho de compras
  CardItemBloc(Product product) {
    // ouve o fluxo de itens , essa lista contém todos os cartItem que estão dentro
    // do carrinho de compras , após isso , verificamos se essa lista contém
    // o produto que recebemos como parâmetro no construtor
    // como a lista é uma lista de CartItem , precisamos criar um objeto de CartItem
    // por o produto dentro dele e após isso , verificar se a lista de CartItem
    // contém esse Item , a função contains irá verificar se já existem esse CartItem na lista
    // retornará true se houver e false se não houver

    _subscription = itensInCartFlux
        .map(
          (dados) => dados.contains(CartItem(product)),
        )
        .listen(isInCartEvent.add);
  }

  void dispose() {
    _subscription?.cancel();
    _itensInCart?.close();
    _isInCart?.close();
  }
}
