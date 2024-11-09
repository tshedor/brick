import 'package:brick_core/src/query/query.dart';
import 'package:brick_core/src/query/where.dart';
import 'package:test/test.dart';

void main() {
  group('Query', () {
    group('properties', () {
      test('#action', () {
        final q = Query(action: QueryAction.delete);
        expect(q.action, QueryAction.delete);
      });

      group('#providerArgs', () {
        test('#providerArgs.page and #providerArgs.sort', () {
          final q = Query(providerArgs: const {'page': 1, 'sort': 'by_user_asc'});

          expect(q.providerArgs['page'], 1);
          expect(q.providerArgs['sort'], 'by_user_asc');
        });

        test('#providerArgs.limit', () {
          final q0 = Query(providerArgs: const {'limit': 0});
          expect(q0.providerArgs['limit'], 0);

          final q10 = Query(providerArgs: const {'limit': 10});
          expect(q10.providerArgs['limit'], 10);

          final q18 = Query(providerArgs: const {'limit': 18});
          expect(q18.providerArgs['limit'], 18);

          expect(
            () => Query(providerArgs: const {'limit': -1}),
            throwsA(const TypeMatcher<AssertionError>()),
          );
        });

        test('#providerArgs.offset', () {
          final q0 = Query(providerArgs: const {'limit': 10, 'offset': 0});
          expect(q0.providerArgs['offset'], 0);

          final q10 = Query(providerArgs: const {'limit': 10, 'offset': 10});
          expect(q10.providerArgs['offset'], 10);

          final q18 = Query(providerArgs: const {'limit': 10, 'offset': 18});
          expect(q18.providerArgs['offset'], 18);

          expect(
            () => Query(providerArgs: const {'offset': -1}),
            throwsA(const TypeMatcher<AssertionError>()),
          );

          expect(
            () => Query(providerArgs: const {'offset': 1}),
            throwsA(const TypeMatcher<AssertionError>()),
          );
        });
      });

      test('#where', () {
        final q = Query(
          where: const [Where('name', value: 'Thomas')],
        );

        expect(q.where!.first.evaluatedField, 'name');
        expect(q.where!.first.value, 'Thomas');
      });
    });

    group('==', () {
      test('properties are the same', () {
        final q1 = Query(
          action: QueryAction.delete,
          providerArgs: const {
            'limit': 3,
            'offset': 3,
          },
        );
        final q2 = Query(
          action: QueryAction.delete,
          providerArgs: const {
            'limit': 3,
            'offset': 3,
          },
        );

        expect(q1, q2);
      });

      test('providerArgs are the same', () {
        final q1 = Query(providerArgs: const {'name': 'Guy'});
        final q2 = Query(providerArgs: const {'name': 'Guy'});

        expect(q1, q2);
      });

      test('providerArgs have different values', () {
        final q1 = Query(providerArgs: const {'name': 'Thomas'});
        final q2 = Query(providerArgs: const {'name': 'Guy'});

        expect(q1, isNot(q2));
      });

      test('providerArgs have different keys', () {
        final q1 = Query(providerArgs: const {'email': 'guy@guy.com'});
        final q2 = Query(providerArgs: const {'name': 'Guy'});

        expect(q1, isNot(q2));
      });

      test('providerArgs are null', () {
        final q1 = Query();
        final q2 = Query(providerArgs: const {'name': 'Guy'});
        expect(q1, isNot(q2));

        final q3 = Query();
        expect(q1, q3);
      });
    });

    group('#copyWith', () {
      test('overrides', () {
        final q1 =
            Query(action: QueryAction.insert, providerArgs: const {'limit': 10, 'offset': 10});
        final q2 = q1.copyWith(providerArgs: const {'limit': 20});
        expect(q2.action, QueryAction.insert);
        expect(q2.providerArgs['limit'], 20);
        expect(q2.providerArgs['offset'], null);

        final q3 = q1.copyWith(providerArgs: const {'limit': 50, 'offset': 20});
        expect(q3.action, QueryAction.insert);
        expect(q3.providerArgs['limit'], 50);
        expect(q3.providerArgs['offset'], 20);
      });

      test('appends', () {
        final q1 = Query(action: QueryAction.insert);
        final q2 = q1.copyWith(providerArgs: const {'limit': 20});

        expect(q1.providerArgs['limit'], null);
        expect(q2.action, QueryAction.insert);
        expect(q2.providerArgs['limit'], 20);
      });
    });

    test('#toJson', () {
      final source = Query(
        action: QueryAction.update,
        providerArgs: const {
          'limit': 3,
          'offset': 3,
        },
      );

      expect(
        source.toJson(),
        {
          'action': 2,
          'providerArgs': {
            'limit': 3,
            'offset': 3,
          },
        },
      );
    });

    group('factories', () {
      test('.fromJson', () {
        final json = {
          'action': 2,
          'providerArgs': {
            'limit': 3,
            'offset': 3,
          },
        };

        final result = Query.fromJson(json);
        expect(
          result,
          Query(
            action: QueryAction.update,
            providerArgs: const {
              'limit': 3,
              'offset': 3,
            },
          ),
        );
      });

      group('.where', () {
        test('required arguments', () {
          final expandedQuery = Query(where: const [Where('id', value: 2)]);
          final factoried = Query.where('id', 2);
          expect(factoried, expandedQuery);
          expect(Where.firstByField('id', factoried.where)!.value, 2);
          expect(factoried.unlimited, isTrue);
        });

        test('limit1:true', () {
          final expandedQuery =
              Query(where: const [Where('id', value: 2)], providerArgs: const {'limit': 1});
          final factoried = Query.where('id', 2, limit1: true);
          expect(factoried, expandedQuery);
          expect(factoried.unlimited, isFalse);
        });
      });
    });
  });
}
