erlbcrypt
=========

erlbcrypt is a wrapper around the OpenBSD Blowfish password hashing
algorithm, as described in `"A Future-Adaptable Password Scheme"`_ by Niels
Provos and David Mazieres.

.. _"A Future-Adaptable Password Scheme":
   http://www.openbsd.org/papers/bcrypt-paper.ps

Try
---
1. Run it (simple way, starting sasl, crypto and bcrypt)
        erl -pa ebin -boot start_sasl -s crypto -s bcrypt

Use
---

1. Hash a password using a salt with the default number of rounds::

        1> {ok, Salt} = erlbcrypt:gen_salt().
        {ok,"$2a$12$sSS8Eg.ovVzaHzi1nUHYK."}
        2> {ok, Hash} = erlbcrypt:hashpw("foo", Salt).
        {ok,"$2a$12$sSS8Eg.ovVzaHzi1nUHYK.HbUIOdlQI0iS22Q5rd5z.JVVYH6sfm6"}

2. Verify the password::

        3> {ok, Hash} =:= erlbcrypt:hashpw("foo", Hash).
        true
        4> {ok, Hash} =:= erlbcrypt:hashpw("bar", Hash).
        false

Configuration
-------------

The bcrypt application is configured by changing values in the
application's environment:

``default_log_rounds``
  Sets the default number of rounds which define the complexity of the
  hash function. Defaults to ``12``.

``mechanism``
  Specifies whether to use the NIF implementation (``'nif'``) or a
  pool of port programs (``'port'``). Defaults to ``'nif'``.

  `Note: the NIF implementation no longer blocks the Erlang VM
  scheduler threads`

``pool_size``
  Specifies the size of the port program pool. Defaults to ``4``.

Authors
-------

* [`Hunter Morris`](http://github.com/skarab)
* [`Mrinal Wadhwa`](http://github.com/mrinalwadhwa)
* [`Bikram Chatterjee`](http://github.com/c-bik)
