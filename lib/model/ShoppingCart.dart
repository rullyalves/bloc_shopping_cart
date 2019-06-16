import 'package:shoppingcart_bloc/model/CartItem.dart';
import 'package:shoppingcart_bloc/model/Product.dart';

// classe do carrinho de compras
class ShoppingCart {
  // lista onde todos os itens de dentro do carrinho estão armazenados
  List<CartItem> _items = <CartItem>[];
// total de valor - soma dos valores de todos os produtos no carrinho de compras
  //double total = 0;
  List<CartItem> get items => _items;
  set items(List<CartItem> items) => _items = items;

  double get total {
    double totalOfValues = 0;
    for (var valor in items) {
      totalOfValues = totalOfValues + valor.total;
    }

    return totalOfValues;
  }

// getter retornando o número de elementos que a nossa lista de itens contém
  int get numOfItems => items?.length;

  // adiciona um item ao carrinho
  void addItem(Product product) {
    CartItem item = CartItem(product);

// adicionando o item dentro da lista do carrinho de compras
    if (!_items.contains(item)) {
      _items?.add(item);
    }
  }

// remove um item do carrinho
  void deleteItem(CartItem item) {
    // remove o item da lista de itens do carrinho
    items?.remove(item);
    //  total = total - item.total;
  }
}
