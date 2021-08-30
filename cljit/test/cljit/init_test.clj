(ns cljit.init-test
  (:require [cljit.init :as init]
            [clojure.test :refer :all]
            [clojure.java.io :as io]))

(defn clear []
  (let [f (io/file "/tmp/.cljit")]
    (when (.exists f) (io/delete-file f))))

(use-fixtures :each
              (fn [f]
                (clear)
                (f)
                (clear)))

(deftest create-dir
  (init/-main "/tmp")

  (let [dir (io/file "/tmp/.cljit")]
    (is (.isDirectory dir))))

(deftest when-dir-already-exists
  (init/-main "/tmp")
  (is (thrown? Exception (init/-main "/tmp"))))
(run-tests)
