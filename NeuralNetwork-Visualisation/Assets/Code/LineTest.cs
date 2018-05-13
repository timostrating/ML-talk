using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineTest : MonoBehaviour {

	LineRenderer lr;


	void Start() {
		lr = GetComponent<LineRenderer>();
	}

	void Update () {
		var t = Time.time;
		for(int i=0; i<10; i++) {
			lr.SetPosition(i, new Vector3(i * 0.5f, Mathf.Sin(i + t), 0.0f));
		}
	}
}
