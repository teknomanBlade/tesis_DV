using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    private bool _isHeld;
    private bool _isWalking;
    private Vector3 _startingPosition;
    private NavMeshAgent _navMeshAgent;
    private LevelManager _lm;
    private Vector3 _exitPos;
    private Animator _animator;

    void Awake()
    {
       
        _startingPosition = transform.position;
        _isHeld = false;
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _animator = GetComponent<Animator>();
        _animator.SetBool("IsIdle", true);
    }

    void Update()
    {

        if(_isHeld == false && Vector3.Distance(transform.position, _startingPosition) > 3f)
        {
            Vector3 dest = default(Vector3);
            dest = _startingPosition;
            var dir = dest - transform.position;
            dir.y = 0f;
            Debug.Log("DISTANCE TO STARTING POS:" + Vector3.Distance(transform.position, _startingPosition));
            if(Vector3.Distance(transform.position, _startingPosition) < 3.025f)
            {
                _animator.SetBool("IsIdle", true);
            }
            _navMeshAgent.destination = dest;
            //transform.rotation = Quaternion.Euler(0, transform.rotation.y, transform.rotation.z);
        }
        //else
        //{
        //    _navMeshAgent.destination = transform.position;
        //}
    }

    public void CatIsBeingTaken()
    {
        _isHeld = true;
        _animator.SetBool("IsMad", true);
        //_navMeshAgent.isStopped = true;
        _navMeshAgent.enabled = false;
    }

    public void CatHasBeenReleased()
    {
        _isHeld = false;
        _animator.SetBool("IsIdle", false);
        _animator.SetBool("IsMad", false);
        _animator.SetBool("IsWalking", true);
        //_navMeshAgent.isStopped = false;
        _navMeshAgent.enabled = true;
    }

    public void SetExitPos(Vector3 exitPos)
    {
        _exitPos = exitPos;
    }

    public float GetDistance()
    {
        return Vector3.Distance(transform.position, _exitPos);
    }


}
