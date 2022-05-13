using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    private bool _isHeld;
    private Vector3 _startingPosition;
    private NavMeshAgent _navMeshAgent;

    void Awake()
    {
        _startingPosition = transform.position;
        _isHeld = false;
        _navMeshAgent = GetComponent<NavMeshAgent>();
    }

    void Update()
    {
        if(_isHeld == false && Vector3.Distance(transform.position, _startingPosition) > 3f)
        {
            Vector3 dest = default(Vector3);
            dest = _startingPosition;
            var dir = dest - transform.position;
            dir.y = 0f;
            _navMeshAgent.destination = dest;
        }
        //else
        //{
        //    _navMeshAgent.destination = transform.position;
        //}
    }

    public void CatIsBeingTaken()
    {
        _isHeld = true;
        //_navMeshAgent.isStopped = true;
        _navMeshAgent.enabled = false;
    }

    public void CatHasBeenReleased()
    {
        _isHeld = false;
        //_navMeshAgent.isStopped = false;
        _navMeshAgent.enabled = true;
    }
}
