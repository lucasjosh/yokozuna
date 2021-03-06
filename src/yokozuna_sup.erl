%% -------------------------------------------------------------------
%%
%% Copyright (c) 2012 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(yokozuna_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).


%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


%%%===================================================================
%%% Callbacks
%%%===================================================================

init(_Args) ->
    SolrProc = {yz_solr_proc_sup,
                {yz_solr_proc_sup, start_link, []},
                permanent, infinity, supervisor, [yz_solr_proc_sup]},
    VMaster = {yokozuna_vnode_master,
               {riak_core_vnode_master, start_link, [yokozuna_vnode]},
               permanent, 5000, worker, [riak_core_vnode_master]},
    Events = {yz_events,
              {yz_events, start_link, []},
              permanent, 5000, worker, [yz_events]},

    {ok, {{one_for_one, 5, 10}, [SolrProc, VMaster, Events]}}.
