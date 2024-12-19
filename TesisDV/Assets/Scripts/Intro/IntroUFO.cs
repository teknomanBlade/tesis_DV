using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class IntroUFO : MonoBehaviour
{
    [SerializeField] private AudioSource _as;
    [SerializeField] private bool _isMoving = false;
    public Vector3 startPos;
    public Vector3 finalPos;

    void Start()
    {
        _isMoving = true;
        transform.position = startPos;
        Debug.Log(transform.position + " " + finalPos);
        _as.Play();
    }

    private void Update()
    {
        if (_isMoving)
        {
            MoveToFinalPos();
        }
    }

    private void MoveToFinalPos()
    {
        if (!_isMoving) return;

        Vector3 direction = (finalPos - transform.position).normalized;

        transform.position += direction * 15 * Time.deltaTime;

        if (Vector3.Distance(transform.position, finalPos) < 0.1f)
        {
            _isMoving = false; 
            Destroy(gameObject);
        }
    }
}
