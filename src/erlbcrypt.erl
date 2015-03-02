%% Copyright (c) 2011 Hunter Morris
%% Distributed under the MIT license; see LICENSE for details.
-module(erlbcrypt).
-author('Hunter Morris <hunter.morris@smarkets.com>').

-behaviour(application).
-behaviour(supervisor).

%% API
-export([mechanism/0]).
-export([gen_salt/0, gen_salt/1, hashpw/2]).

% Shell start/stop
-export([start/0, stop/0]).

% Application callbacks
-export([start/2, stop/1]).

% Supervisor callbacks
-export([init/1]).

start() -> application:start(?MODULE).
stop()  -> application:stop(?MODULE).

mechanism() ->
    {ok, M} = application:get_env(?MODULE, mechanism),
    M.

gen_salt() -> do_gen_salt(mechanism()).
gen_salt(Rounds) -> do_gen_salt(mechanism(), Rounds).
hashpw(Password, Salt) -> do_hashpw(mechanism(), Password, Salt).

do_gen_salt(nif)  -> bcrypt_nif_worker:gen_salt();
do_gen_salt(port) -> bcrypt_pool:gen_salt().

do_gen_salt(nif, Rounds)  -> bcrypt_nif_worker:gen_salt(Rounds);
do_gen_salt(port, Rounds) -> bcrypt_pool:gen_salt(Rounds).

do_hashpw(nif, Password, Salt)  -> bcrypt_nif_worker:hashpw(Password, Salt);
do_hashpw(port, Password, Salt) -> bcrypt_pool:hashpw(Password, Salt).

%% ----------------------------------------------------------------------------
%% Supervisor callbacks
%% ----------------------------------------------------------------------------
start(_Type, _Args) ->
    case supervisor:start_link({local, ?MODULE}, ?MODULE, []) of
        {ok, Pid}          -> {ok, Pid};
        {error, _} = Error -> Error
    end.

stop(_State) -> ok.
%% ----------------------------------------------------------------------------

%% ----------------------------------------------------------------------------
%% Supervisor callbacks
%% ----------------------------------------------------------------------------
init([]) ->
    PortChildren
        = [{bcrypt_port_sup, {bcrypt_port_sup, start_link, []}, permanent,
            16#ffffffff, supervisor, [bcrypt_port_sup]},
           {bcrypt_pool, {bcrypt_pool, start_link, []}, permanent,
            16#ffffffff, worker, [bcrypt_pool]}],
    NifChildren
        = [{bcrypt_nif_worker, {bcrypt_nif_worker, start_link, []}, permanent,
            16#ffffffff, worker, [bcrypt_nif_worker]}],
    case application:get_env(?MODULE, mechanism) of
        undefined  -> {stop, no_mechanism_defined};
        {ok, nif}  -> {ok, {{one_for_all, 1, 1}, NifChildren}};
        {ok, port} -> {ok, {{one_for_all, 15, 60}, PortChildren}}
    end.
%% ----------------------------------------------------------------------------
