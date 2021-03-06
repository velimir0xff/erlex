-module(chap3).
%%%===================================================================
%%% API
%%%===================================================================
-export([sum/1, sum/2,
         create/1, reverse_create/1, 
         print_ints/1, print_even/1,
         filter/2, reverse/1,
         concatenate/1, flatten/1,
         quick_sort/1, merge_sort/1,
         len/1, split/2, merge/2]).

%% 3.1 Function sum/1
%% N - upperbound
%% return the sum of all the integers between 1 and N
sum(N) when N > 1 ->
    N + sum(N - 1);
sum(1) ->
    1.

%% 3.1 Function sum/2
%% N - lowerbound
%% M - upperbound
%% return the sum of the interval between N and M [N, M]
%% throw badarg when N > M
sum(N, M) when N < M ->
    M + sum(N, M - 1);
sum(N, N) ->
    N;
sum(N, M) when N > M ->
    throw({badarg, M}).

%% 3.2 Function create/1
%% N - value of the last element in the list
%% return [1, 2, ..., N - 1, N] sequence
create(N) when N < 0 ->
    throw({badarg, N});
create(N) -> create_acc(N, []).
%% acc function for create/1
create_acc(0, List) -> List;
create_acc(N, List) -> create_acc(N - 1, [N|List]).

%% 3.2 Function reverse_create/1
%% N - value of the first element in the list
%% return [N, N - 1, ..., 2, 1] sequence
reverse_create(0) ->
    [];
reverse_create(N) when N < 0 ->
    throw({badarg, N});
reverse_create(N) ->
    [N|reverse_create(N - 1)].

%% 3.3 print_ints - print to stdout number in format "Number:~p~n"
%% N - max number in sequnce
print_ints(N) when N > 0 ->
    print_ints(N - 1),
    io:format("Number:~p~n", [N]);
%% how to avoid this clause?
print_ints(0) -> 0.

%% 3.3 print_even - print to stdout number in format "Number:~p~n"
%% only if it's even
%% N - max number in sequnce
print_even(N) when N rem 2 == 0, N > 0 ->
    print_even(N - 1),
    io:format("Number:~p~n", [N]);
print_even(N) when N > 0 ->
    print_even(N - 1);
%% how to avoid this clause?
print_even(0) -> 0.

%% 3.5 Manipulating Lists
%% filter - return all integers smaller than or equal to given integer
%% List - list of  integers
%% N - upperbound
filter(List, N) ->
    case List of
        [] -> [];
        [H|T] when H =< N ->
            [H|filter(T, N)];
        [_|T] -> filter(T, N)
    end.

%% reverse - return reversed version of given list
%% List - list that should be reversed
reverse(List) ->
    reverse_acc(List, []).

reverse_acc([H|T], Acc) ->
    reverse_acc(T, [H|Acc]);
reverse_acc([], Acc) -> Acc.


%% concatenate
%% concatenate all given lists and return it
%% Lists - list of lists
concatenate(Lists) ->
    case Lists of
        [] -> [];
        [H|T] -> concatenate(H, concatenate(T))
    end.

%% concatenate two give lists
%% TODO: should we append small list to bigger one?
concatenate([], Dst) ->
    Dst;
concatenate(Src, []) ->
    Src;
concatenate([H|T], Dst) ->
    [H|concatenate(T, Dst)].

%% flatten
%% return a flat list of given list of lists
%% Lists - list of lists
flatten(Lists) ->
    case Lists of
        [] -> [];
        [H|T] -> concatenate(flatten(H), flatten(T));
        L -> [L]
    end.

%% 3.6 Sorting Lists
%% quick sort
quick_sort([]) -> [];
quick_sort([H|T]) ->
    case smaller(T, H) of
        {Smalls, Rests} ->
            quick_sort(Smalls) ++ [H] ++ quick_sort(Rests)
    end.

%% split
%% return tuple with smaller and rest lists compare to Pivot element
%% List - input list
%% Pivot - each element in list'll be compared with pivot
smaller(List, Pivot) ->
    smaller_acc(List, Pivot, [], []).

smaller_acc([], _Pivot, Smalls, Rests) ->
    {reverse(Smalls), reverse(Rests)};
smaller_acc([H|T], Pivot, Smalls, Rests) ->
    if
        H < Pivot ->
            smaller_acc(T, Pivot, [H|Smalls], Rests);
        true ->
            smaller_acc(T, Pivot, Smalls, [H|Rests])
    end.

%% merge sorting
%% List - input list
%% return sorted list
merge_sort(List) ->
    case len(List) of
        0 -> List;
        1 -> List;
        N -> [Lh, Rh] = split(List, N div 2),
             merge(merge_sort(Rh), merge_sort(Lh))
    end.

%% return length of the list
len([]) -> 0;
len([_|T]) ->
    1 + len(T).

%% split List on to two lists with first list of length N
%% List - input list
%% N - first list size
split(List, N) ->
    split_acc(List, N, []).

split_acc(List, 0, Acc) ->
    [reverse(Acc), List];
split_acc([H|T], N, Acc) ->
    split_acc(T, N - 1, [H|Acc]).


%% merge two sorted lists
%% Lh - first list
%% Rh - second list
%% return merged sorted list
merge(Lh, Rh) ->
    reverse(merge_acc(Lh, Rh, [])).

merge_acc([], [], Acc) ->
    Acc;
merge_acc([], [H|T], Acc) ->
    merge_acc([], T, [H|Acc]);
merge_acc([H|T], [], Acc) ->
    merge_acc(T, [], [H|Acc]);
merge_acc([LhHead|LT], [RhHead|RT], Acc) ->
    if
        LhHead < RhHead ->
            merge_acc(LT, [RhHead|RT], [LhHead|Acc]);
        true ->
            merge_acc([LhHead|LT], RT, [RhHead|Acc])
    end.


%%%===================================================================
%%% Tests
%%%===================================================================
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

sum_test_() ->
    [
     ?_assertEqual(1, sum(1)),
     ?_assertEqual(55, sum(10)),
     ?_assertError(_Error, sum(0))
    ].

sum_2_test_() ->
    [
     ?_assertEqual(0, sum(0, 0)),
     ?_assertEqual(1, sum(0, 1)),
     ?_assertEqual(1, sum(1, 1)),
     ?_assertEqual(sum(10), sum(1, 10)),
     ?_assertThrow({badarg, 0}, sum(1, 0))
    ].

create_test_() ->
    [
     ?_assertEqual([1, 2, 3], create(3)),
     ?_assertEqual([], create(0)),
     ?_assertThrow({badarg, -1}, create(-1))
    ].

reverse_create_test_() ->
    [
     ?_assertEqual([3, 2, 1], reverse_create(3)),
     ?_assertEqual([], reverse_create(0)),
     ?_assertThrow({badarg, -1}, reverse_create(-1))
    ].

filter_test_() ->
    [
     ?_assertEqual([], filter([], 0)),
     ?_assertEqual([-2, -1, 0], filter([-2, -1, 0, 1, 2], 0)),
     ?_assertEqual([-2, -1], filter([-2, -1, 0, 1, 2], -1)),
     ?_assertEqual([], filter([-2, -1, 0, 1, 2], -3)),
     ?_assertEqual([-2, -1, 0, 1, 2], filter([-2, -1, 0, 1, 2], 2))
    ].

reverse_test_() ->
    [
     ?_assertEqual([4, 3, 2, 1], reverse([1, 2, 3, 4])),
     ?_assertEqual([], reverse([])),
     ?_assertEqual([3, 2, 1], reverse([1, 2, 3]))
    ].

concatenate_test_() ->
    [
     ?_assertEqual([], concatenate([])),
     ?_assertEqual([1, 2], concatenate([[1], [2]])),
     ?_assertEqual([1, 2, 3], concatenate([[1], [2], [3]])),
     ?_assertEqual([1,2,3,4,5,6], concatenate([[1, 2], [3, 4], [5, 6]]))     
    ].

-endif.
