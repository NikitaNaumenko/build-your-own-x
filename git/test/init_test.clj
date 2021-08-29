(ns init-test
  (:require [init]
            [clojure.test :refer :all]
            [clojure.java.io :as io]))

(defn clear []
  (let [f (io/file "/tmp/.git")]
    (when (.exists f) (io/delete-file f))))

(use-fixtures :each
              (fn [f]
                (clear)
                (f)
                (clear)))

(deftest create-dir
  (init/-main "/tmp")

  (let [dir (io/file "/tmp/.git")]
    (is (.isDirectory dir))))
