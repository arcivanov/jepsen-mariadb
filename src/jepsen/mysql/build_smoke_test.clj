(ns jepsen.mysql.build-smoke-test
  "A trivial workload that opens a connection and runs SELECT 1. Validates
  that MariaDB starts and Jepsen can connect without risking analysis failures."
  (:require [jepsen [checker :as checker]
                    [client :as client]
                    [generator :as gen]]
            [jepsen.mysql [client :as c]]
            [next.jdbc :as j]))

(defrecord Client [conn]
  client/Client
  (open! [this test node]
    (assoc this :conn (c/open test node)))

  (setup! [_ _test])

  (invoke! [_ _test op]
    (let [result (j/execute-one! conn ["SELECT 1 AS v"])]
      (assoc op :type :ok, :value (:v result))))

  (teardown! [_ _test])

  (close! [_ _test]
    (c/close! conn)))

(defn workload
  [_opts]
  {:generator (gen/limit 10 (repeat {:f :select-1, :value nil}))
   :checker   (reify checker/Checker
                (check [_ _ _ _]
                  {:valid? true}))
   :client    (Client. nil)})
