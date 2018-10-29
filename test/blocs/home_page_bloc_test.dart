import 'package:beatz/blocs/home_page_bloc.dart';
import 'package:test/test.dart';

main() {
  test('test HomePageBloc gives the right output and in order', () async {
    HomePageBloc bloc = HomePageBloc();
    bloc.pageIndex.add(1);
    bloc.pageIndex.add(3);
    bloc.pageIndex.add(0);
    expect(
        bloc.pageIndexStream,
        emitsInOrder([
          emits((val) => val == 1),
          emits((val) => val == 3),
          emits((val) => val == 0),
        ]));
  });
}
