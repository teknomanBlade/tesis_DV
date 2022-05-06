using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVTrap : MonoBehaviour
{
    private bool _canStun;
    private float _timePassed;
    private float _recoveryTime = 6f;
    [SerializeField]
    private LayerMask targetMask;
    void Start()
    {
        _canStun = true;
        _timePassed = _recoveryTime;
    }

    // Update is called once per frame
    void Update()
    {
        if(!_canStun)
        {
            _timePassed -= Time.deltaTime;
        }
        else
        {
            _canStun = true;
            _timePassed = _recoveryTime;
        }
    }

    void OnTriggerEnter(Collider collision)
    {
        Debug.Log("1");
        if(_canStun)
        {
            Debug.Log("2");
            //if (collision.gameObject.layer == targetMask)
            //{
                Debug.Log("3");
                collision.gameObject.GetComponent<Gray>().Stun(3f);
            //}
        }
    }
}
